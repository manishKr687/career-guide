"use client";

import { useState } from "react";
import { FieldConfig, FieldOption, FormValues, PairFieldConfig, RowFieldConfig } from "@/lib/admin/resourceConfig";

const BASE_INPUT_CLASS =
  "w-full rounded-xl border border-line px-3.5 py-2.5 text-[13.5px] font-medium text-ink focus:outline-none focus:border-navy/30 focus:ring-2 focus:ring-navy/5 transition-colors disabled:bg-bg-soft disabled:text-subtle";

export type FieldValue = string | number | boolean | string[] | Array<Record<string, string>> | undefined;

/**
 * Search-as-you-type replacement for a plain checkbox list. Some of these
 * (Skills, Careers) have 50-200+ options, and scrolling a flat unfiltered
 * checkbox list to find a handful of them was the single biggest reported
 * admin UX complaint -- this narrows the list as you type, shows what's
 * already picked as removable chips, and drops picked items out of the
 * browse list below so it shrinks as you go.
 */
function MultiSelectField({
  value,
  onChange,
  options,
  disabled,
}: {
  value: string[];
  onChange: (value: string[]) => void;
  options: FieldOption[];
  disabled: boolean;
}) {
  const [query, setQuery] = useState("");
  const selected = new Set(value);
  const selectedOptions = options.filter((o) => selected.has(o.value));
  const normalizedQuery = query.trim().toLowerCase();
  const availableOptions = options.filter((o) => !selected.has(o.value));
  const filteredOptions = normalizedQuery
    ? availableOptions.filter((o) => o.label.toLowerCase().includes(normalizedQuery))
    : availableOptions;

  function add(v: string) {
    onChange([...value, v]);
    setQuery("");
  }
  function remove(v: string) {
    onChange(value.filter((x) => x !== v));
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter") {
      // Add the top match so a fast "type, Enter, type, Enter" flow works
      // for adding several items in a row without touching the mouse.
      e.preventDefault();
      if (filteredOptions.length > 0) add(filteredOptions[0].value);
    } else if (e.key === "Backspace" && query === "" && value.length > 0) {
      // Quick-remove the last chip when the search box is empty, matching
      // the convention most tag/chip pickers use.
      remove(value[value.length - 1]);
    }
  }

  return (
    <div className={`rounded-xl border border-line ${disabled ? "bg-bg-soft" : "bg-white"}`}>
      {selectedOptions.length > 0 && (
        <div className="flex flex-wrap gap-1.5 p-3 pb-2.5">
          {selectedOptions.map((opt) => (
            <span
              key={opt.value}
              className="inline-flex items-center gap-1.5 text-[12.5px] font-bold pl-2.5 pr-1.5 py-1 rounded-full bg-navy/8 text-navy"
            >
              {opt.label}
              {!disabled && (
                <button
                  type="button"
                  onClick={() => remove(opt.value)}
                  aria-label={`Remove ${opt.label}`}
                  className="text-navy/50 hover:text-navy leading-none text-[15px]"
                >
                  &times;
                </button>
              )}
            </span>
          ))}
        </div>
      )}

      {!disabled && (
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={handleKeyDown}
          disabled={options.length === 0}
          placeholder={
            options.length === 0
              ? "No options available yet."
              : `Search ${options.length} option${options.length === 1 ? "" : "s"}...`
          }
          className={`w-full text-[13px] font-medium text-ink placeholder:text-subtle focus:outline-none px-3 py-2.5 ${
            selectedOptions.length > 0 ? "border-t border-line" : ""
          }`}
        />
      )}

      {!disabled && options.length > 0 && (
        <div className="max-h-44 overflow-y-auto border-t border-line">
          {filteredOptions.length === 0 ? (
            <p className="text-[12.5px] text-subtle px-3 py-2.5">
              {normalizedQuery ? "No matches." : "All options selected."}
            </p>
          ) : (
            filteredOptions.map((opt) => (
              <button
                key={opt.value}
                type="button"
                onClick={() => add(opt.value)}
                className="block w-full text-left text-[13px] text-ink px-3 py-2 hover:bg-bg-soft transition-colors"
              >
                {opt.label}
              </button>
            ))
          )}
        </div>
      )}
    </div>
  );
}

/**
 * Editor for a "pairs" field -- a list of (A, B) records (e.g. College's
 * careerOfferings: {careerSlug, degreeSlug}). Generic over which two
 * option lists/labels/object keys it uses via `pairConfig`, so the next
 * relation shaped like this reuses this component instead of a new one.
 */
/**
 * An ordered list of small typed records -- Career's growth ladder and salary
 * bands. Rows are editable in place and reorderable, because for both of these
 * the ORDER IS THE DATA: rung 2 of a ladder is not rung 4, and the server
 * rewrites sort_order from the position in this list.
 *
 * A blank optional column posts null, not zero. That is how "open-ended" is
 * said -- the last growth rung has no upper year, the top salary band has no
 * ceiling -- and zero would be a different, wrong claim.
 */
function RowListField({
  value,
  onChange,
  rowConfig,
  disabled,
}: {
  value: Array<Record<string, string>>;
  onChange: (value: Array<Record<string, string>>) => void;
  rowConfig: RowFieldConfig;
  disabled?: boolean;
}) {
  function update(index: number, key: string, next: string) {
    onChange(value.map((row, i) => (i === index ? { ...row, [key]: next } : row)));
  }

  function move(index: number, delta: number) {
    const target = index + delta;
    if (target < 0 || target >= value.length) return;
    const next = [...value];
    [next[index], next[target]] = [next[target], next[index]];
    onChange(next);
  }

  return (
    <div className="flex flex-col gap-2">
      {value.map((row, index) => (
        <div
          key={index}
          className="flex flex-wrap items-end gap-2 rounded-xl border border-line bg-bg-soft p-3"
        >
          {rowConfig.columns.map((c) => (
            <label key={c.key} className="flex flex-col gap-1 flex-1 min-w-[120px]">
              <span className="text-[10.5px] font-bold uppercase tracking-wide text-subtle">
                {c.label}
                {c.optional ? " (optional)" : ""}
              </span>
              <input
                type={c.type === "number" ? "number" : "text"}
                step={c.type === "number" ? "any" : undefined}
                value={row[c.key] ?? ""}
                placeholder={c.placeholder}
                onChange={(e) => update(index, c.key, e.target.value)}
                disabled={disabled}
                className="rounded-lg border border-line px-3 py-2 text-[13.5px] bg-white disabled:opacity-50"
              />
            </label>
          ))}
          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={() => move(index, -1)}
              disabled={disabled || index === 0}
              aria-label="Move up"
              className="w-8 h-9 rounded-lg border border-line bg-white text-navy text-[13px] disabled:opacity-30"
            >
              &uarr;
            </button>
            <button
              type="button"
              onClick={() => move(index, 1)}
              disabled={disabled || index === value.length - 1}
              aria-label="Move down"
              className="w-8 h-9 rounded-lg border border-line bg-white text-navy text-[13px] disabled:opacity-30"
            >
              &darr;
            </button>
            <button
              type="button"
              onClick={() => onChange(value.filter((_, i) => i !== index))}
              disabled={disabled}
              aria-label="Remove row"
              className="w-8 h-9 rounded-lg border border-line bg-white text-red text-[13px] disabled:opacity-30"
            >
              &times;
            </button>
          </div>
        </div>
      ))}
      <button
        type="button"
        onClick={() =>
          onChange([
            ...value,
            Object.fromEntries(rowConfig.columns.map((c) => [c.key, ""])) as Record<string, string>,
          ])
        }
        disabled={disabled}
        className="self-start text-[13px] font-semibold text-navy bg-white border border-line rounded-lg px-4 py-2 hover:border-navy/30 disabled:opacity-50"
      >
        {rowConfig.addLabel}
      </button>
    </div>
  );
}

function PairListField({
  value,
  onChange,
  pairConfig,
  optionsA,
  optionsB,
  bAppliesToAValues,
  disabled,
}: {
  value: Array<Record<string, string>>;
  onChange: (value: Array<Record<string, string>>) => void;
  pairConfig: PairFieldConfig;
  optionsA: FieldOption[];
  optionsB: FieldOption[];
  bAppliesToAValues: string[];
  disabled: boolean;
}) {
  const [keyA, keyB] = pairConfig.keys;
  const [labelA, labelB] = pairConfig.labels;
  const optionalB = pairConfig.optionalB ?? false;

  const [draftA, setDraftA] = useState("");
  const [draftB, setDraftB] = useState("");
  // When `bAppliesToA` is configured, the B side only applies for certain A
  // values -- for education, only degrees whose `requiresSubject` is true.
  // Offering "Subject" next to MBBS invites "MBBS in Physics", which the
  // database would accept and which means nothing. With no A chosen yet the
  // select stays enabled so it doesn't look broken on an empty row.
  const bApplies =
    !pairConfig.bAppliesToA || !draftA || bAppliesToAValues.includes(draftA);

  const labelFor = (options: FieldOption[], v: string) => options.find((o) => o.value === v)?.label ?? v;

  function addPair() {
    // With optionalB the B side may be left blank -- education needs that,
    // since a fused qualification like MBBS has no separate subject and
    // requiring one would make those rows unenterable.
    if (!draftA || (!optionalB && !draftB)) return;
    if (value.some((row) => row[keyA] === draftA && (row[keyB] ?? "") === draftB)) return;
    onChange([...value, { [keyA]: draftA, [keyB]: draftB }]);
    setDraftA("");
    setDraftB("");
  }

  function removePair(index: number) {
    onChange(value.filter((_, i) => i !== index));
  }

  return (
    <div className={`rounded-xl border border-line ${disabled ? "bg-bg-soft" : "bg-white"} p-3`}>
      {value.length > 0 && (
        <div className="flex flex-col gap-1.5 mb-3">
          {value.map((row, index) => (
            <div
              key={`${row[keyA]}-${row[keyB]}-${index}`}
              className="flex items-center justify-between gap-2 text-[12.5px] font-semibold text-navy bg-navy/8 rounded-lg px-3 py-2"
            >
              <span>
                {labelFor(optionsA, row[keyA])}
                {row[keyB] ? <> &rarr; {labelFor(optionsB, row[keyB])}</> : null}
              </span>
              {!disabled && (
                <button
                  type="button"
                  onClick={() => removePair(index)}
                  aria-label={`Remove ${row[keyA]} to ${row[keyB]}`}
                  className="text-navy/50 hover:text-navy leading-none text-[15px]"
                >
                  &times;
                </button>
              )}
            </div>
          ))}
        </div>
      )}

      {!disabled && (
        <div className="flex flex-wrap items-center gap-2">
          <select
            value={draftA}
            onChange={(e) => {
              setDraftA(e.target.value);
              // Drop a subject already picked for a different degree, so
              // switching to MBBS cannot silently carry "Physics" along.
              if (pairConfig.bAppliesToA && !bAppliesToAValues.includes(e.target.value)) {
                setDraftB("");
              }
            }}
            className="flex-1 min-w-[140px] rounded-lg border border-line px-2.5 py-2 text-[13px]"
          >
            <option value="">{labelA}...</option>
            {optionsA.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
          <select
            value={bApplies ? draftB : ""}
            onChange={(e) => setDraftB(e.target.value)}
            disabled={!bApplies}
            title={
              bApplies
                ? undefined
                : `${labelFor(optionsA, draftA)} takes no ${labelB.toLowerCase()}`
            }
            className="flex-1 min-w-[140px] rounded-lg border border-line px-2.5 py-2 text-[13px] disabled:bg-bg-soft disabled:text-subtle"
          >
            <option value="">
              {bApplies ? `${labelB}...` : `No ${labelB.toLowerCase()}`}
            </option>
            {optionsB.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
          <button
            type="button"
            onClick={addPair}
            disabled={!draftA || (!optionalB && !draftB)}
            className="text-[12.5px] font-bold text-white bg-navy px-3 py-2 rounded-lg disabled:opacity-40"
          >
            Add
          </button>
        </div>
      )}
    </div>
  );
}

/** Renders one input matching a FieldConfig's type, fully controlled from the parent form's state. */
function FieldInput({
  field,
  value,
  onChange,
  options,
  referenceOptions,
  disabled,
}: {
  field: FieldConfig;
  value: FieldValue;
  onChange: (value: FieldValue) => void;
  options: FieldOption[];
  referenceOptions: Record<string, FieldOption[]>;
  disabled: boolean;
}) {
  const label = (
    <label className="block text-[13px] font-bold text-ink mb-1.5">
      {field.label}
      {field.required && <span className="text-red ml-1">*</span>}
    </label>
  );
  const helpText = field.helpText ? <p className="text-[12px] text-subtle mt-1">{field.helpText}</p> : null;

  let control: React.ReactNode;
  switch (field.type) {
    case "textarea":
      control = (
        <textarea
          value={typeof value === "string" ? value : ""}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          rows={3}
          className={BASE_INPUT_CLASS}
        />
      );
      break;
    case "number":
      control = (
        <input
          type="number"
          value={typeof value === "number" ? String(value) : ""}
          onChange={(e) => onChange(e.target.value === "" ? undefined : Number(e.target.value))}
          disabled={disabled}
          className={BASE_INPUT_CLASS}
        />
      );
      break;
    case "select":
      control = (
        <select
          value={typeof value === "string" ? value : ""}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          className={BASE_INPUT_CLASS}
        >
          <option value="" disabled>
            Select...
          </option>
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      );
      break;
    case "tags":
      control = (
        <input
          type="text"
          value={Array.isArray(value) ? value.join(", ") : ""}
          onChange={(e) =>
            onChange(
              e.target.value
                .split(",")
                .map((s) => s.trim())
                .filter((s) => s !== "")
            )
          }
          disabled={disabled}
          className={BASE_INPUT_CLASS}
        />
      );
      break;
    case "multiselect":
      control = (
        <MultiSelectField
          value={Array.isArray(value) ? (value as string[]) : []}
          onChange={onChange}
          options={options}
          disabled={disabled}
        />
      );
      break;
    case "pairs":
      control = field.pairConfig ? (
        <PairListField
          value={Array.isArray(value) ? (value as Array<Record<string, string>>) : []}
          onChange={onChange}
          pairConfig={field.pairConfig}
          optionsA={referenceOptions[field.pairConfig.optionsKeys[0]] ?? []}
          optionsB={referenceOptions[field.pairConfig.optionsKeys[1]] ?? []}
          bAppliesToAValues={
            field.pairConfig.bAppliesToA
              ? (referenceOptions[field.pairConfig.bAppliesToA] ?? []).map((o) => o.value)
              : []
          }
          disabled={disabled}
        />
      ) : null;
      break;
    case "rows":
      control = field.rowConfig ? (
        <RowListField
          value={Array.isArray(value) ? (value as Array<Record<string, string>>) : []}
          onChange={onChange}
          rowConfig={field.rowConfig}
          disabled={disabled}
        />
      ) : null;
      break;
    case "date":
      control = (
        <input
          type="date"
          value={typeof value === "string" ? value : ""}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          className={BASE_INPUT_CLASS}
        />
      );
      break;
    case "boolean":
      control = (
        <label className="flex items-center gap-2 text-[13px] text-ink">
          <input
            type="checkbox"
            checked={value === true}
            disabled={disabled}
            onChange={(e) => onChange(e.target.checked)}
          />
          Yes
        </label>
      );
      break;
    case "text":
    default:
      control = (
        <input
          type="text"
          value={typeof value === "string" ? value : ""}
          onChange={(e) => onChange(e.target.value)}
          disabled={disabled}
          className={BASE_INPUT_CLASS}
        />
      );
  }

  return (
    <div>
      {label}
      {control}
      {helpText}
    </div>
  );
}

export default function AdminEntityForm({
  fields,
  values,
  onChange,
  referenceOptions,
  disabledFields = [],
  className = "space-y-5",
}: {
  fields: FieldConfig[];
  values: FormValues;
  onChange: (key: string, value: FieldValue) => void;
  referenceOptions: Record<string, FieldOption[]>;
  disabledFields?: string[];
  /** Container layout. Each FieldInput renders a single div, so a grid works
   *  here as well as the default stack -- the edit dialog uses two columns. */
  className?: string;
}) {
  return (
    <div className={className}>
      {fields.map((field) => (
        <FieldInput
          key={field.key}
          field={field}
          value={values[field.key]}
          onChange={(v) => onChange(field.key, v)}
          options={field.optionsKey ? referenceOptions[field.optionsKey] ?? [] : field.staticOptions ?? []}
          referenceOptions={referenceOptions}
          disabled={disabledFields.includes(field.key)}
        />
      ))}
    </div>
  );
}
