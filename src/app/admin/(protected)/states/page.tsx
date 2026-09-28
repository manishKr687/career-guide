import AdminResourceList from "@/components/admin/AdminResourceList";
import { RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";

export default async function Page() {
  const initialItems = await RESOURCE_CONFIGS["states"].loadAll();
  return <AdminResourceList resource="states" initialItems={initialItems} />;
}
