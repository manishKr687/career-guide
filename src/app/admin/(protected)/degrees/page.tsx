import AdminResourceList from "@/components/admin/AdminResourceList";
import { RESOURCE_CONFIGS } from "@/lib/admin/resourceConfig";

export default async function Page() {
  const initialItems = await RESOURCE_CONFIGS["degrees"].loadAll();
  return <AdminResourceList resource="degrees" initialItems={initialItems} />;
}
