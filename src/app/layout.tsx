import type { Metadata } from "next";
import { SITE_URL } from "@/lib/siteUrl";
import "./globals.css";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import { ToastProvider } from "@/components/ui/Toast";
import CompareBar from "@/components/ui/CompareBar";
import { UserProvider } from "@/components/providers/UserProvider";
import { SavedItemsProvider } from "@/components/providers/SavedItemsProvider";

const TITLE = "CareerGuide — Your Complete Career Journey";
const DESCRIPTION =
  "From school to career and beyond. Explore careers, degrees, exams and colleges, take a career assessment, and build your personalized roadmap — for every stage of your journey.";

export const metadata: Metadata = {
  // Without metadataBase, every relative URL Next resolves for Open Graph and
  // canonical tags is left relative -- which means link previews on WhatsApp and
  // LinkedIn, the two places students actually share things, resolve against the
  // wrong host and render blank. It is inert in development and only matters the
  // moment the site is public, which is why it is easy to ship without.
  metadataBase: new URL(SITE_URL),
  title: {
    default: TITLE,
    // Detail pages already set their own full title, so this only applies to
    // pages that set a bare one.
    template: "%s | CareerGuide",
  },
  description: DESCRIPTION,
  openGraph: {
    type: "website",
    siteName: "CareerGuide",
    title: TITLE,
    description: DESCRIPTION,
    locale: "en_IN",
    url: SITE_URL,
  },
  twitter: {
    card: "summary_large_image",
    title: TITLE,
    description: DESCRIPTION,
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full flex flex-col font-sans antialiased text-ink bg-white">
        <ToastProvider>
          <UserProvider>
            <SavedItemsProvider>
              <Navbar />
              <main className="flex-1">{children}</main>
              <Footer />
              <CompareBar />
            </SavedItemsProvider>
          </UserProvider>
        </ToastProvider>
      </body>
    </html>
  );
}
