"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { AdminResource, adminCreate, adminUpdate, AdminUnauthorizedError } from "@/lib/adminApi";
import { ApiError } from "@/lib/api";
import { FieldOption, FormValues, RESOURCE_CONFIGS, toFormValues, toPayload } from "@/lib/admin/resourceConfig";
import AdminEntityForm, { FieldValue } from "@/components/admin/AdminEntityForm";

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

  if (loadError) {
    return <p className="text-[13.5px] text-red">{loadError}</p>;
  }
  if (!values) {
    return <p className="text-[13.5px] text-subtle">Loading...</p>;
  }

  return (
    <div>
      <h1 className="font-display font-extrabold text-navy text-xl mb-6">
        {mode === "create" ? `New ${config.label}` : `Edit ${config.label}`}
      </h1>
      <form onSubmit={handleSubmit} className="max-w-2xl space-y-5">
        <AdminEntityForm
          fields={config.fields}
          values={values}
          onChange={handleChange}
          referenceOptions={referenceOptions}
          disabledFields={mode === "edit" ? ["slug"] : []}
        />
        {submitError && <p className="text-[13.5px] text-red">{submitError}</p>}
        <div className="flex gap-3 pt-2">
          <button
            type="submit"
            disabled={submitting}
            className="text-[13.5px] font-bold text-white bg-navy px-5 py-3 rounded-xl hover:bg-navy-2 transition-colors disabled:opacity-50"
          >
            {submitting ? "Saving..." : "Save"}
          </button>
          <button
            type="button"
            onClick={() => router.push(`/admin/${resource}`)}
            className="text-[13.5px] font-bold text-navy bg-white px-5 py-3 rounded-xl border border-line hover:border-navy/30 transition-colors"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
