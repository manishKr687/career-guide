import AdminResourceList from "@/components/admin/AdminResourceList";
import { RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";

export default async function Page() {
  const initialItems = await RESOURCE_CONFIGS["resources"].loadAll();
  return <AdminResourceList resource="resources" initialItems={initialItems} />;
}
