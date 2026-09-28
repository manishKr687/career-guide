import AdminResourceList from "@/components/admin/AdminResourceList";
import { RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";

export default async function Page() {
  const initialItems = await RESOURCE_CONFIGS["industries"].loadAll();
  return <AdminResourceList resource="industries" initialItems={initialItems} />;
}
