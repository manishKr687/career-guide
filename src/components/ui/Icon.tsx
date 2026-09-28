import { cn } from "@/lib/utils";

const ICON_PATHS: Record<string, string> = {
  rocket:
    '<path d="M12 2.5c3 2 5 6 4 12L12 19l-4-4.5c-1-6 1-10 4-12Z"/><path d="M9.3 15 6.5 17.8 8 21l2.8-2.8M14.7 15l2.8 2.8L16 21l-2.8-2.8"/><circle cx="12" cy="9.2" r="1.6"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="M16.6 16.6 21 21"/>',
  cap: '<path d="M2 8 12 3l10 5-10 5L2 8Z"/><path d="M6 10.2V16c0 1.9 2.7 3.4 6 3.4s6-1.5 6-3.4v-5.8"/><path d="M22 8v6"/>',
  book: '<path d="M12 5.2c-2.4-1.6-6-1.6-9-.3v13.4c3-1.3 6.6-1.3 9 .3 2.4-1.6 6-1.6 9-.3V4.9c-3-1.3-6.6-1.3-9 .3Z"/><path d="M12 5.2v13.4"/>',
  compass: '<circle cx="12" cy="12" r="9"/><path d="M15 9l-2 5-5 2 2-5 5-2Z"/>',
  chart: '<path d="M4 20V10M10 20V4M16 20v-7M4 20h16"/>',
  brief:
    '<rect x="3" y="7.5" width="18" height="12" rx="2.2"/><path d="M9 7.5V5.8A1.8 1.8 0 0 1 10.8 4h2.4A1.8 1.8 0 0 1 15 5.8v1.7"/><path d="M3 12.5h18"/>',
  flask:
    '<path d="M9.5 2.5h5M10 2.5v6.3L4.7 18a2.1 2.1 0 0 0 1.8 3.1h11a2.1 2.1 0 0 0 1.8-3.1L14 8.8V2.5"/><path d="M7.5 15h9"/>',
  steth:
    '<path d="M5.5 3v6.7a4.3 4.3 0 0 0 8.6 0V3"/><path d="M5.5 3H4M14.1 3h1.5"/><path d="M14.1 9.7v2.6a5.6 5.6 0 0 0 11.2 0v-1.4" transform="translate(-3.3 0)"/><circle cx="20.5" cy="11" r="1.4"/>',
  scale:
    '<path d="M12 3.5v17M6 20.5h12M3.3 8h6M14.7 8h6"/><path d="M6.3 8 3.3 13.5a3 3 0 0 0 6 0L6.3 8ZM17.7 8l-3 5.5a3 3 0 0 0 6 0L17.7 8Z"/>',
  palette:
    '<path d="M12 3a9 6.7 0 1 0 0 13.4c1 0 1.8-.7 1.8-1.7 0-.5-.2-.9-.5-1.2-.3-.3-.5-.7-.5-1.2 0-.9.8-1.7 1.8-1.7H17a4 4 0 0 0 4-4C21 4.9 16.9 3 12 3Z"/><circle cx="7.3" cy="10.5" r="0.9" fill="currentColor"/><circle cx="9.5" cy="7" r="0.9" fill="currentColor"/><circle cx="14.3" cy="6.7" r="0.9" fill="currentColor"/>',
  code: '<path d="M8.5 7 3 12l5.5 5M15.5 7 21 12l-5.5 5"/>',
  bank: '<path d="M3 9.5 12 4l9 5.5"/><path d="M4.5 9.5V19M9 9.5V19M15 9.5V19M19.5 9.5V19M2.5 20.5h19"/>',
  shield:
    '<path d="M12 3 19.5 6v5.2c0 5-3.2 8.4-7.5 9.8-4.3-1.4-7.5-4.8-7.5-9.8V6L12 3Z"/><path d="M8.6 12.2l2.3 2.3 4.5-4.5"/>',
  leaf: '<path d="M19.5 4.5c-9 0-14 5-14 15 9 0 14-5 14-15Z"/><path d="M6.3 17.7c3-3 6-6 10.5-10.7"/>',
  plane:
    '<path d="M21.5 2.5 2 10l7.6 2.9L12.6 21l3-8.4 5.9-10.1Z"/><path d="M9.6 12.9 21.5 2.5"/>',
  mega:
    '<path d="M3 9.7v4.6h3.2l7.8 3.7V6L6.2 9.7H3Z"/><path d="M17 8.3a5.2 5.2 0 0 1 0 7.4"/><path d="M8 17v2.6a1.4 1.4 0 0 1-2.7.4L4.4 17"/>',
  wrench:
    '<path d="M20.2 7.3a4.6 4.6 0 0 1-6.1 5.9L6 21.3l-2.3-2.3 8.1-8.1a4.6 4.6 0 0 1 5.9-6.1l-3.1 3.1 1.6 1.6 3-3.1Z"/>',
  trophy:
    '<path d="M7.5 3h9v6a4.5 4.5 0 0 1-9 0V3Z"/><path d="M7.5 5H4.8A2.7 2.7 0 0 0 7.5 8M16.5 5h2.7a2.7 2.7 0 0 1-2.7 3M10.5 14v3h3v-3M8.3 20.5h7.4M12 17v3.5"/>',
  bulb: '<path d="M9 18h6M10 21h4M12 3a6.3 6.3 0 0 0-3.8 11.3c.9.7 1.3 1.4 1.3 2.4h5c0-1 .4-1.7 1.3-2.4A6.3 6.3 0 0 0 12 3Z"/>',
  users:
    '<circle cx="9" cy="8" r="3.1"/><path d="M2.8 20c0-3.8 2.8-6 6.2-6s6.2 2.2 6.2 6"/><circle cx="17.3" cy="9" r="2.3"/><path d="M15.5 20c0-2.9 1.8-5 4.6-5.4"/>',
  target: '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.3" fill="currentColor"/>',
  clip:
    '<rect x="5" y="4" width="14" height="17.5" rx="2.2"/><rect x="9" y="2.2" width="6" height="3.2" rx="1"/><path d="M8.2 10.5h7.6M8.2 13.8h7.6M8.2 17h5"/>',
  cal: '<rect x="3.2" y="5" width="17.6" height="16" rx="2.2"/><path d="M3.2 9.6h17.6M8 3v4M16 3v4"/>',
  bld: '<rect x="5" y="3" width="14" height="18" rx="1.5"/><path d="M9 7h1.4M13.6 7H15M9 11h1.4M13.6 11H15M9 15h1.4M13.6 15H15"/><rect x="10.2" y="17" width="3.6" height="4"/>',
  doc: '<path d="M6.5 2.5h8l4 4v14.5a1 1 0 0 1-1 1h-11a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1Z"/><path d="M14.5 2.5v4h4"/><path d="M8.5 11.5h7M8.5 14.7h7M8.5 17.9h4.5"/>',
  star: '<path d="M12 3.3l2.7 5.5 6 .9-4.4 4.2 1 6-5.3-2.8-5.3 2.8 1-6-4.4-4.2 6-.9L12 3.3Z"/>',
  heart:
    '<path d="M12 20.5S3.5 15.4 3.5 9.4A4.9 4.9 0 0 1 12 6a4.9 4.9 0 0 1 8.5 3.4c0 6-8.5 11.1-8.5 11.1Z"/>',
  gear: '<circle cx="12" cy="12" r="3.2"/><path d="M12 3v2.4M12 18.6V21M21 12h-2.4M5.4 12H3M18.1 5.9l-1.7 1.7M7.6 16.5l-1.7 1.7M18.1 18.1l-1.7-1.7M7.6 7.6 5.9 5.9"/>',
  trend: '<path d="M3 17 9 11 13 15 21 6"/><path d="M15 6h6v6"/>',
  layers: '<path d="M12 3 21 8l-9 5-9-5 9-5Z"/><path d="M3 12l9 5 9-5M3 16l9 5 9-5"/>',
  mappin: '<path d="M12 21s7-6.5 7-11.5a7 7 0 0 0-14 0C5 14.5 12 21 12 21Z"/><circle cx="12" cy="9.5" r="2.4"/>',
  check: '<path d="M4 12.5 9.5 18 20 6"/>',
  arrowRight: '<path d="M2 12h18M14 6l6 6-6 6"/>',
  chevRight: '<path d="M8 4l8 8-8 8"/>',
  arrowDown: '<path d="M12 3v16M6 13l6 6 6-6"/>',
  phone: '<rect x="7" y="2" width="10" height="20" rx="2.4"/><path d="M10.7 19h2.6"/>',
  monitor: '<rect x="3" y="4" width="18" height="13" rx="1.6"/><path d="M8 21h8M12 17v4"/>',
  award: '<circle cx="12" cy="8.5" r="5.5"/><path d="M9 13.2 7 21l5-2.7 5 2.7-2-7.8"/>',
  filter: '<path d="M3.5 4.5h17L14 12.5v6l-4 2v-8L3.5 4.5Z"/>',
  // The grid/list pair, added for the careers listing's view toggle. `layers`
  // and `menu` were standing in for them, and neither reads as what it does.
  grid: '<rect x="3.5" y="3.5" width="7" height="7" rx="1.6"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.6"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.6"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.6"/>',
  list: '<path d="M8 6h13M8 12h13M8 18h13"/><circle cx="4" cy="6" r="1.2"/><circle cx="4" cy="12" r="1.2"/><circle cx="4" cy="18" r="1.2"/>',
  teach:
    '<rect x="3" y="4" width="18" height="12.5" rx="1.6"/><path d="M9.5 20.5h5M8 8.3l3 2.4 5-3.7"/>',
  switch:
    '<path d="M3.5 8h13.2M13.5 4.3 16.7 8l-3.2 3.7M20.5 16H7.3M10.5 12.3 7.3 16l3.2 3.7"/>',
  menu: '<path d="M4 7h16M4 12h16M4 17h16"/>',
  close: '<path d="M6 6l12 12M18 6 6 18"/>',
  external: '<path d="M14 5h5v5"/><path d="M19 5 10 14"/><path d="M18 13v5a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5"/>',
  user: '<circle cx="12" cy="8.5" r="3.6"/><path d="M4.5 20c0-4 3.4-6.5 7.5-6.5s7.5 2.5 7.5 6.5"/>',
  building: '<path d="M3 21h18"/><path d="M5 21V6l7-3 7 3v15"/><path d="M9 21v-5h6v5"/><path d="M9 9h1.5M13.5 9H15M9 13h1.5M13.5 13H15"/>',
  bolt: '<path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z"/>',
  chip: '<rect x="7" y="7" width="10" height="10" rx="1.5"/><path d="M7 3v3M12 3v3M17 3v3M7 18v3M12 18v3M17 18v3M3 7h3M3 12h3M3 17h3M18 7h3M18 12h3M18 17h3"/>',
  train: '<rect x="5" y="4" width="14" height="13" rx="4"/><path d="M5 11h14"/><path d="M9 17.5 6.5 21M15 17.5l2.5 3.5"/><circle cx="9" cy="14" r="0.9" fill="currentColor"/><circle cx="15" cy="14" r="0.9" fill="currentColor"/>',
  mail: '<rect x="3" y="5" width="18" height="14" rx="2.2"/><path d="M3.5 6.5 12 13l8.5-6.5"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7.3V12l3.3 2"/>',
  pulse: '<path d="M2.5 12.5h4l2-6 3.5 12 2.5-9 1.5 3h5.5"/>',
  ship: '<path d="M4 14.5h16l-2 5.5H6l-2-5.5Z"/><path d="M6.5 14.5V5.5h4V3h3v2.5h1.5l3 6.5"/><path d="M2.5 20.5c1.6 1.2 3.4 1.2 5 0 1.6 1.2 3.4 1.2 5 0 1.6 1.2 3.4 1.2 5 0"/>',
  pickaxe: '<path d="M4.5 20 13 11.5"/><path d="M10 8.5c1.6-2.5 5-3.9 8-3 1.8.5 3.2 1.7 4 3.3-.4 1.9-1.5 3.6-3.1 4.7-2.4 1.7-5.5 1.9-8.1.7"/>',
  robot: '<rect x="5" y="9" width="14" height="10" rx="2.2"/><circle cx="9.3" cy="14" r="1.3" fill="currentColor"/><circle cx="14.7" cy="14" r="1.3" fill="currentColor"/><path d="M9 19v2M15 19v2M12 9V5.5"/><circle cx="12" cy="4" r="1.3"/><path d="M2.5 13v3M21.5 13v3"/>',
};

interface IconProps {
  name: keyof typeof ICON_PATHS | string;
  className?: string;
  strokeWidth?: number;
}

export default function Icon({ name, className, strokeWidth = 1.8 }: IconProps) {
  const inner = ICON_PATHS[name] ?? ICON_PATHS.circle ?? "";
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={cn("shrink-0", className)}
      aria-hidden="true"
      dangerouslySetInnerHTML={{ __html: inner }}
    />
  );
}

export { ICON_PATHS };
