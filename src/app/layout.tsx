import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
import { ToastProvider } from "@/components/ui/Toast";
import CompareBar from "@/components/ui/CompareBar";
import { UserProvider } from "@/components/providers/UserProvider";
import { SavedItemsProvider } from "@/components/providers/SavedItemsProvider";

export const metadata: Metadata = {
  title: "CareerGuide — Your Complete Career Journey",
  description:
    "From school to career and beyond. Explore careers, degrees, exams and colleges, take a career assessment, and build your personalized roadmap — for every stage of your journey.",
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
