"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AdminResource, adminCreate, adminUpdate, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { FieldOption, FieldType, FormValues, RESOURCE_CONFIGS, toFormValues, toPayload } from "@/lib/admin/resourceConfig";
import Link from "next/link";
import Icon from "@/components/ui/Icon";
import Breadcrumb from "@/components/ui/Breadcrumb";
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
const SECTIONS: Array<{ title: string; blurb: string; types: FieldType[]; aside?: boolean }> = [
  {
    title: "Basic Information",
    blurb: "The core details of this record.",
    types: ["text", "select", "number", "boolean", "date", "tags"],
  },
  {
    title: "Description",
    blurb: "The longer copy that the public pages render.",
    types: ["textarea"],
  },
  {
    title: "Relationships",
    blurb: "Links to other entities. These drive what appears on the public pages.",
    types: ["multiselect"],
    aside: true,
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
  const [activeTab, setActiveTab] = useState(0);

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

  // Split into the two columns. Relationships sit beside the form rather than
  // under it: they are reference pickers rather than things you write, and on a
  // record with twenty of them they would otherwise bury the fields you came to
  // change.
  const mainSections = sections.filter((s) => !s.aside);
  const asideSections = sections.filter((s) => s.aside);
  const tab = mainSections[Math.min(activeTab, mainSections.length - 1)];

  return (
    <form onSubmit={handleSubmit} className="pb-4">
      <Breadcrumb
        items={[{ label: config.pluralLabel, href: listHref }, { label: `${mode === "create" ? "New" : "Edit"} ${config.label}` }]}
      />

      <div className="mb-6">
        <h2 className="font-display font-extrabold text-navy text-[26px] leading-tight">
          {mode === "create" ? `New ${config.label}` : `Edit ${config.label}`}
        </h2>
        <p className="text-[13px] text-muted mt-1">
          {mode === "create"
            ? `Create a new ${config.label.toLowerCase()} and its related information.`
            : `Update ${config.label.toLowerCase()} details, description, and related information.`}
        </p>
      </div>

      {/* Tabs only where there is more than one group to move between; on States
          and Industries there is a single section and a tab strip of one is
          furniture. */}
      {mainSections.length > 1 && (
        <div className={`${SURFACE} px-2 mb-6 overflow-x-auto`}>
          <div className="flex items-center gap-1" role="tablist">
            {mainSections.map((section, i) => (
              <button
                key={section.title}
                type="button"
                role="tab"
                aria-selected={i === activeTab}
                onClick={() => setActiveTab(i)}
                className={`relative text-[13px] font-bold px-4 py-3.5 whitespace-nowrap transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue/30 rounded-lg ${
                  i === activeTab ? "text-blue" : "text-muted hover:text-navy"
                }`}
              >
                {section.title}
                {i === activeTab && (
                  <span className="absolute left-3 right-3 -bottom-px h-0.5 bg-blue rounded-full" />
                )}
              </button>
            ))}
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 items-start">
        <div className="xl:col-span-2 flex flex-col gap-6">
          {tab && (
            <SectionCard
              step={activeTab + 1}
              title={tab.title}
              blurb={tab.blurb}
            >
              <AdminEntityForm
                fields={tab.fields}
                values={values}
                onChange={handleChange}
                referenceOptions={referenceOptions}
                disabledFields={mode === "edit" ? ["slug"] : []}
                className={
                  tab.types.includes("textarea") || tab.types.includes("pairs")
                    ? "space-y-5"
                    : "grid grid-cols-1 sm:grid-cols-2 gap-x-5 gap-y-5"
                }
              />
            </SectionCard>
          )}
        </div>

        <aside className="flex flex-col gap-6 xl:sticky xl:top-20">
          {asideSections.map((section, i) => (
            <SectionCard
              key={section.title}
              step={mainSections.length + i + 1}
              title={section.title}
              blurb={section.blurb}
            >
              <AdminEntityForm
                fields={section.fields}
                values={values}
                onChange={handleChange}
                referenceOptions={referenceOptions}
              />
            </SectionCard>
          ))}

          <SectionCard step={mainSections.length + asideSections.length + 1} title="Actions" blurb="">
            <div className="flex flex-wrap justify-end gap-3">
              <button type="button" onClick={() => router.push(listHref)} className={BTN_SECONDARY}>
                Cancel
              </button>
              <button type="submit" disabled={submitting} className={BTN_PRIMARY}>
                {submitting ? "Saving..." : mode === "create" ? `Create ${config.label}` : `Update ${config.label}`}
              </button>
            </div>
          </SectionCard>
        </aside>
      </div>

      {submitError && <Toast tone="error" message={submitError} onClose={() => setSubmitError(null)} />}
    </form>
  );
}

/** A numbered panel. The step number is the design's main navigational cue on a
 *  long form -- it tells you where you are without reading the heading. */
function SectionCard({
  step,
  title,
  blurb,
  children,
}: {
  step: number;
  title: string;
  blurb: string;
  children: React.ReactNode;
}) {
  return (
    <section className={SURFACE}>
      <div className="flex items-start gap-3 px-5 py-4 border-b border-line">
        <span className="w-7 h-7 rounded-full bg-blue text-white text-[12.5px] font-bold flex items-center justify-center shrink-0">
          {step}
        </span>
        <div className="min-w-0">
          <h3 className="font-display font-extrabold text-navy text-[15px]">{title}</h3>
          {blurb && <p className="text-[12px] text-muted mt-0.5">{blurb}</p>}
        </div>
      </div>
      <div className="px-5 py-5">{children}</div>
    </section>
  );
}
