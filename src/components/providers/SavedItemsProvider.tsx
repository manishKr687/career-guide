"use client";

import { createContext, useCallback, useContext, useEffect, useRef, useState } from "react";
import { useUser } from "@/components/providers/UserProvider";
import { useToast } from "@/components/ui/Toast";
import {
  SavedType,
  getSavedSlugs as getLocalSavedSlugs,
  toggleSaved as toggleLocalSaved,
} from "@/lib/savedItems";
import { SavedEntityType, getSavedEntitySlugs, saveEntity, unsaveEntity } from "@/lib/userApi";

type SavedSets = Record<SavedType, Set<string>>;

function emptySets(): SavedSets {
  return { careers: new Set(), colleges: new Set(), exams: new Set() };
}

interface SavedItemsContextValue {
  isSaved: (type: SavedType, slug: string) => boolean;
  toggleSaved: (type: SavedType, slug: string) => Promise<boolean>;
  /** All currently-saved slugs for one type -- server-backed once logged in, localStorage otherwise. Empty until `ready`. */
  getSavedSlugs: (type: SavedType) => string[];
  ready: boolean;
}

const SavedItemsContext = createContext<SavedItemsContextValue | null>(null);

/**
 * Server-backed once logged in (SavedItemsController, V31), localStorage
 * otherwise -- see lib/savedItems.ts for the anonymous fallback. On login,
 * any locally-saved slugs are pushed to the server once (a slug already
 * saved server-side is left alone) and then cleared locally, so a save made
 * before signing in isn't lost, and a later logout doesn't resurrect an
 * already-migrated slug from stale local storage.
 */
export function SavedItemsProvider({ children }: { children: React.ReactNode }) {
  const { user } = useUser();
  const { showToast } = useToast();
  const [sets, setSets] = useState<SavedSets>(emptySets);
  const [ready, setReady] = useState(false);
  // Guards against migrating twice if `user` reference changes without a
  // real logout/login in between (e.g. a `refresh()` re-fetching the same
  // account) -- migration should run once per actual login.
  const migratedForUserId = useRef<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    const types: SavedType[] = ["careers", "colleges", "exams"];

    async function loadLoggedOut() {
      const next = emptySets();
      for (const type of types) {
        next[type] = new Set(getLocalSavedSlugs(type));
      }
      if (!cancelled) {
        setSets(next);
        setReady(true);
      }
    }

    async function loadLoggedIn(userId: number) {
      const shouldMigrate = migratedForUserId.current !== userId;
      const next = emptySets();
      // Slugs actually pushed to the server *this run* -- not the same
      // thing as "how many saved items the account ends up with", which is
      // what this used to be measured by (see below).
      let migratedCount = 0;
      for (const type of types) {
        const entityType = type as SavedEntityType;
        let serverSlugs: string[];
        try {
          serverSlugs = (await getSavedEntitySlugs<{ slug: string }>(entityType)).map((item) => item.slug);
        } catch {
          serverSlugs = [];
        }
        const serverSet = new Set(serverSlugs);

        if (shouldMigrate) {
          const localSlugs = getLocalSavedSlugs(type);
          const toMigrate = localSlugs.filter((slug) => !serverSet.has(slug));
          for (const slug of toMigrate) {
            try {
              await saveEntity(entityType, slug);
              serverSet.add(slug);
              // Remove only this slug now that it's confirmed saved
              // server-side. Calling clearSavedType(type) here (the old
              // behavior) wiped every local slug of this type once the loop
              // finished, including ones whose saveEntity call had just
              // failed in the catch below -- silently discarding them
              // instead of leaving them for a later retry, as the comment
              // there always claimed.
              toggleLocalSaved(type, slug);
              migratedCount += 1;
            } catch {
              // Leave it in local storage if the migration call fails (e.g.
              // the slug no longer exists) -- not worth blocking login
              // over, and it'll be retried on a future login.
            }
          }
        }

        next[type] = serverSet;
      }
      migratedForUserId.current = userId;
      if (!cancelled) {
        setSets(next);
        setReady(true);
        // Bug this replaces: `shouldMigrate` recomputes true on every page
        // refresh (migratedForUserId is a ref, which doesn't survive a full
        // reload), and the old toast condition counted the account's total
        // saved-item count post-load rather than what was actually migrated
        // this run -- so anyone with existing saved items saw this toast on
        // every refresh forever, not just the one time something was
        // actually carried over from local storage.
        if (migratedCount > 0) {
          showToast("Your saved items are now synced to your account", "success");
        }
      }
    }

    // eslint-disable-next-line react-hooks/set-state-in-effect
    setReady(false);
    if (user) {
      loadLoggedIn(user.id);
    } else {
      loadLoggedOut();
    }
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user]);

  const isSaved = useCallback((type: SavedType, slug: string) => sets[type].has(slug), [sets]);

  const getSavedSlugs = useCallback((type: SavedType) => Array.from(sets[type]), [sets]);

  const toggleSaved = useCallback(
    async (type: SavedType, slug: string) => {
      const currentlySaved = sets[type].has(slug);

      if (!user) {
        const nowSaved = toggleLocalSaved(type, slug);
        setSets((prev) => {
          const next = { ...prev, [type]: new Set(prev[type]) };
          if (nowSaved) next[type].add(slug);
          else next[type].delete(slug);
          return next;
        });
        return nowSaved;
      }

      // Optimistic update -- reverted below if the server call fails.
      setSets((prev) => {
        const next = { ...prev, [type]: new Set(prev[type]) };
        if (currentlySaved) next[type].delete(slug);
        else next[type].add(slug);
        return next;
      });

      try {
        if (currentlySaved) {
          await unsaveEntity(type as SavedEntityType, slug);
        } else {
          await saveEntity(type as SavedEntityType, slug);
        }
        return !currentlySaved;
      } catch {
        setSets((prev) => {
          const next = { ...prev, [type]: new Set(prev[type]) };
          if (currentlySaved) next[type].add(slug);
          else next[type].delete(slug);
          return next;
        });
        showToast("Couldn't save right now. Please try again.", "error");
        return currentlySaved;
      }
    },
    [sets, user, showToast]
  );

  return (
    <SavedItemsContext.Provider value={{ isSaved, toggleSaved, getSavedSlugs, ready }}>
      {children}
    </SavedItemsContext.Provider>
  );
}

export function useSavedItems() {
  const ctx = useContext(SavedItemsContext);
  if (!ctx) throw new Error("useSavedItems must be used within a SavedItemsProvider");
  return ctx;
}
