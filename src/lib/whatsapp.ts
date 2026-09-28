/**
 * The counselling team's own WhatsApp number for the public "Chat with us
 * on WhatsApp" button, e.g. "+919876543210". Optional -- if unset, that
 * button is simply not shown (see CounsellingForm), so there's no broken
 * link risk from forgetting to configure it. Set
 * NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER in .env.local to enable it.
 */
const BUSINESS_WHATSAPP_NUMBER = process.env.NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER?.trim();

/** WhatsApp's click-to-chat links need digits only (with country code) -- no "+", spaces, or punctuation. */
function toWhatsAppDigits(phone: string): string {
  return phone.replace(/[^0-9]/g, "");
}

/** Builds a wa.me click-to-chat link to the given phone number, optionally with a prefilled message. */
export function buildWhatsAppLink(phone: string, message?: string): string {
  const digits = toWhatsAppDigits(phone);
  const query = message ? `?text=${encodeURIComponent(message)}` : "";
  return `https://wa.me/${digits}${query}`;
}

/** A click-to-chat link to the business's own WhatsApp number, or null if NEXT_PUBLIC_COUNSELLING_WHATSAPP_NUMBER isn't configured. */
export function getBusinessWhatsAppLink(message?: string): string | null {
  if (!BUSINESS_WHATSAPP_NUMBER) return null;
  return buildWhatsAppLink(BUSINESS_WHATSAPP_NUMBER, message);
}
