import AdminResourceList from "@/components/admin/AdminResourceList";
import { RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";

export default async function Page() {
  const initialItems = await RESOURCE_CONFIGS["careers"].loadAll();
  return <AdminResourceList resource="careers" initialItems={initialItems} />;
}
