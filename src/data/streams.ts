import { Stream } from "@/lib/types";
import { apiGet, apiGetOptional } from "@/lib/api";

export async function getStreams(): Promise<Stream[]> {
  return apiGet<Stream[]>("/api/streams");
}

export async function getStream(slug: string): Promise<Stream | undefined> {
  const stream = await apiGetOptional<Stream>(`/api/streams/${encodeURIComponent(slug)}`);
  return stream ?? undefined;
}

// There are only 4 streams total (see the Stream type's doc comment), and
// no backend filter param for "streams at this stage" -- fetching all of
// them and filtering here costs nothing at this scale, same reasoning as
// getCareersBySkill/getCareersByIndustry.
export async function getStreamsByStage(stageSlug: string): Promise<Stream[]> {
  const streams = await getStreams();
  return streams.filter((s) => s.stageSlugs.includes(stageSlug));
}
