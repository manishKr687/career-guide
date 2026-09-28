"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AdminResource, adminCreate, adminUpdate, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { FieldOption, FieldType, FormValues, RESOURCE_CONFIGS, toFormValues, toPayload } from "@/lib/admin/resourceConfig";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import { BTN_PRIMARY, BTN_SECONDARY, SURFACE, Toast } from "@/components/admin/AdminKit";
import AdminEntityForm, { FieldValue } from "@/components/admin/AdminEntityForm";

/**
 * Sections, derived from field type rather than hand-annotated.
 *
 * Careers carry 27 fields and Colleges 20. As one flat column that is a long
 * scroll with no landmarks, and the Save button sits at the bottom of it. Adding
 * a `group` to every field across thirteen configs would be ~150 edits to
 * express something the types already imply, so the split is computed: what the
 * entity IS, what it LINKS TO, and the structured tables that need room.
 */
const SECTIONS: Array<{ title: string; blurb: string; types: FieldType[] }> = [
  {
    title: "Details",
    blurb: "The entity's own fields.",
    types: ["text", "textarea", "number", "select", "boolean", "date", "tags"],
  },
  {
    title: "Relationships",
    blurb: "Links to other entities. These drive what appears on the public pages.",
    types: ["multiselect"],
  },
  {
    title: "Structured data",
    blurb: "Ordered tables -- each row is a record in its own right.",
    types: ["pairs", "rows"],
  },
];

function isFilled(value: FieldValue): boolean {
  if (value === undefined) return false;
  if (typeof value === "string") return value.trim() !== "";
  // Arrays (skills, related*, tags) and numbers (0 is valid) are never
  // reported as "missing" here -- only text-ish required fields are.
  return true;
}

export default function AdminResourceForm({
  resource,
  mode,
  slug,
}: {
  resource: AdminResource;
  mode: "create" | "edit";
  slug?: string;
}) {
  const router = useRouter();
  const config = RESOURCE_CONFIGS[resource];

  const [values, setValues] = useState<FormValues | null>(null);
  const [referenceOptions, setReferenceOptions] = useState<Record<string, FieldOption[]>>({});
  const [loadError, setLoadError] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    let cancelled = false;
    Promise.all([
      config.loadReferenceOptions(),
      mode === "edit" ? config.loadAll() : Promise.resolve([] as FormValues[]),
    ])
      .then(([options, all]) => {
        if (cancelled) return;
        setReferenceOptions(options);
        if (mode === "edit") {
          const existing = all.find((item) => String(item.slug) === slug);
          if (!existing) {
            setLoadError(`No ${config.label.toLowerCase()} found with slug "${slug}".`);
            return;
          }
          setValues(toFormValues(config, existing));
        } else {
          setValues(toFormValues(config));
        }
      })
      .catch((err) => {
        if (cancelled) return;
        setLoadError(err instanceof ApiError ? err.message : "Could not reach the API. Is the backend running?");
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [resource, mode, slug]);

  function handleChange(key: string, value: FieldValue) {
    setValues((prev) => (prev ? { ...prev, [key]: value } : prev));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!values) return;

    const missing = config.fields.filter((f) => f.required && !isFilled(values[f.key]));
    if (missing.length > 0) {
      setSubmitError(`Please fill in: ${missing.map((f) => f.label).join(", ")}`);
      return;
    }

    setSubmitError(null);
    setSubmitting(true);
    try {
      const payload = toPayload(config, values);
      if (mode === "create") {
        await adminCreate(resource, payload);
      } else {
        await adminUpdate(resource, slug as string, payload);
      }
      router.push(`/admin/${resource}`);
    } catch (err) {
      if (err instanceof AdminUnauthorizedError) {
        router.push("/admin/login");
        return;
      }
      setSubmitError(err instanceof ApiError ? err.message : "Save failed. Is the backend running?");
    } finally {
      setSubmitting(false);
    }
  }

  const listHref = `/admin/${resource}`;

  if (loadError) {
    return (
      <div>
        <Link href={listHref} className="inline-flex items-center gap-1.5 text-[13px] font-bold text-muted hover:text-navy mb-5">
          <Icon name="arrowRight" className="w-4 h-4 rotate-180" />
          Back to {config.pluralLabel}
        </Link>
        <div className="bg-white rounded-2xl border border-line p-6 max-w-lg">
          <h2 className="flex items-center gap-2 font-display font-extrabold text-navy text-[15px]">
            <Icon name="shield" className="w-[18px] h-[18px] text-red shrink-0" />
            Could not open this form
          </h2>
          <p className="text-[13px] text-muted leading-relaxed mt-2">{loadError}</p>
        </div>
      </div>
    );
  }

  if (!values) {
    // A skeleton rather than the word "Loading...", so the page does not jump
    // from one line of text to a full form.
    return (
      <div>
        <div className="h-5 w-40 rounded bg-line animate-pulse mb-6" />
        <div className="bg-white rounded-2xl border border-line p-6 space-y-5 max-w-3xl">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i}>
              <div className="h-3 w-28 rounded bg-line animate-pulse mb-2" />
              <div className="h-10 rounded-xl bg-line/60 animate-pulse" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  const sections = SECTIONS.map((section) => ({
    ...section,
    fields: config.fields.filter((f) => section.types.includes(f.type)),
  })).filter((section) => section.fields.length > 0);

  return (
    <form onSubmit={handleSubmit} className="max-w-3xl pb-28">
      <Link
        href={listHref}
        className="inline-flex items-center gap-1.5 text-[13px] font-bold text-muted hover:text-navy mb-4"
      >
        <Icon name="arrowRight" className="w-4 h-4 rotate-180" />
        Back to {config.pluralLabel}
      </Link>

      <div className="flex flex-wrap items-baseline gap-3 mb-6">
        <h2 className="font-display font-extrabold text-navy text-[22px]">
          {mode === "create" ? `New ${config.label}` : `Edit ${config.label}`}
        </h2>
        {mode === "edit" && (
          <span className="font-mono text-[12px] text-subtle bg-bg-soft border border-line rounded-lg px-2 py-1">
            {slug}
          </span>
        )}
      </div>

      <div className="flex flex-col gap-5">
        {sections.map((section) => (
          <section key={section.title} className={SURFACE}>
            <div className="px-5 py-4 border-b border-line">
              <h3 className="font-display font-extrabold text-navy text-[14.5px]">{section.title}</h3>
              <p className="text-[12px] text-muted mt-0.5">{section.blurb}</p>
            </div>
            <div className="px-5 py-5">
              <AdminEntityForm
                fields={section.fields}
                values={values}
                onChange={handleChange}
                referenceOptions={referenceOptions}
                disabledFields={mode === "edit" ? ["slug"] : []}
              />
            </div>
          </section>
        ))}
      </div>

      {/* Fixed rather than at the end of the form. On Careers the last field is
          about two screens down, and a Save button you have to scroll to find is
          a Save button people forget to press. */}
      <div className="fixed bottom-0 left-0 right-0 lg:left-60 bg-white/95 backdrop-blur border-t border-line z-20">
        <div className="max-w-3xl px-4 sm:px-6 py-3.5 flex items-center gap-3">
          <button type="submit" disabled={submitting} className={BTN_PRIMARY}>
            {submitting ? "Saving..." : mode === "create" ? `Create ${config.label}` : "Save changes"}
          </button>
          <button type="button" onClick={() => router.push(listHref)} className={BTN_SECONDARY}>
            Cancel
          </button>
        </div>
      </div>

      {/* A save failure at the bottom of a long form is easy to scroll past, and
          the reader's attention is on the action bar, not the page. */}
      {submitError && <Toast tone="error" message={submitError} onClose={() => setSubmitError(null)} />}
    </form>
  );
}
