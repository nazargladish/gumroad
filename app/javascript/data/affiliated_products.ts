import { cast } from "ts-safe-cast";

import { request, ResponseError } from "$app/utils/request";

import { PaginationProps } from "$app/components/Pagination";
import { AffiliatedProduct, SortKey } from "$app/components/server-components/AffiliatedPage";
import { Sort } from "$app/components/useSortingTableDriver";

type PagedAffiliatedProductsData = {
  affiliated_products: AffiliatedProduct[];
  pagination: PaginationProps;
};

export const getPagedAffiliatedProducts = (page?: number, query?: string, sort?: Sort<SortKey> | null) => {
  const abort = new AbortController();
  const response = request({
    method: "GET",
    accept: "json",
    url: Routes.products_affiliated_index_path({ page, query, sort }),
    abortSignal: abort.signal,
  })
    .then((res) => res.json())
    .then((json) => cast<PagedAffiliatedProductsData>(json));

  return {
    response,
    cancel: () => abort.abort(),
  };
};

export async function removeAffiliateAccount(affiliateId: string) {
  const response = await request({
    method: "DELETE",
    accept: "json",
    url: Routes.products_affiliated_path(affiliateId),
  });
  const parsed = cast<{ success: boolean }>(await response.json());
  if (!response.ok || !parsed.success) throw new ResponseError();
}
