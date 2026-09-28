import AdminResourceForm from "@/components/admin/AdminResourceForm";

export default async function Page({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return <AdminResourceForm resource="certifications" mode="edit" slug={slug} />;
}
