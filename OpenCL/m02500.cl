/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_simd.cl"
#include "inc_hash_md5.cl"
#include "inc_hash_sha1.cl"

#define COMPARE_S "inc_comp_single.cl"
#define COMPARE_M "inc_comp_multi.cl"

void hmac_sha1_run_V (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u32x ipad[5], u32x opad[5], u32x digest[5])
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = 0x80000000;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 20) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);
}

__kernel void m02500_init (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global wpa_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const wpa_t *wpa_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  /**
   * base
   */

  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];
  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];
  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];
  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = pws[gid].i[14];
  w3[3] = pws[gid].i[15];

  w0[0] = swap32_S (w0[0]);
  w0[1] = swap32_S (w0[1]);
  w0[2] = swap32_S (w0[2]);
  w0[3] = swap32_S (w0[3]);
  w1[0] = swap32_S (w1[0]);
  w1[1] = swap32_S (w1[1]);
  w1[2] = swap32_S (w1[2]);
  w1[3] = swap32_S (w1[3]);
  w2[0] = swap32_S (w2[0]);
  w2[1] = swap32_S (w2[1]);
  w2[2] = swap32_S (w2[2]);
  w2[3] = swap32_S (w2[3]);
  w3[0] = swap32_S (w3[0]);
  w3[1] = swap32_S (w3[1]);
  w3[2] = swap32_S (w3[2]);
  w3[3] = swap32_S (w3[3]);

  sha1_hmac_ctx_t sha1_hmac_ctx;

  sha1_hmac_init (&sha1_hmac_ctx, w0, w1, w2, w3);

  tmps[gid].ipad[0] = sha1_hmac_ctx.ipad.h[0];
  tmps[gid].ipad[1] = sha1_hmac_ctx.ipad.h[1];
  tmps[gid].ipad[2] = sha1_hmac_ctx.ipad.h[2];
  tmps[gid].ipad[3] = sha1_hmac_ctx.ipad.h[3];
  tmps[gid].ipad[4] = sha1_hmac_ctx.ipad.h[4];

  tmps[gid].opad[0] = sha1_hmac_ctx.opad.h[0];
  tmps[gid].opad[1] = sha1_hmac_ctx.opad.h[1];
  tmps[gid].opad[2] = sha1_hmac_ctx.opad.h[2];
  tmps[gid].opad[3] = sha1_hmac_ctx.opad.h[3];
  tmps[gid].opad[4] = sha1_hmac_ctx.opad.h[4];

  sha1_hmac_update_global_swap (&sha1_hmac_ctx, salt_bufs[salt_pos].salt_buf, salt_bufs[salt_pos].salt_len);

  for (u32 i = 0, j = 1; i < 8; i += 5, j += 1)
  {
    sha1_hmac_ctx_t sha1_hmac_ctx2 = sha1_hmac_ctx;

    w0[0] = j;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    sha1_hmac_update_64 (&sha1_hmac_ctx2, w0, w1, w2, w3, 4);

    sha1_hmac_final (&sha1_hmac_ctx2);

    tmps[gid].dgst[i + 0] = sha1_hmac_ctx2.opad.h[0];
    tmps[gid].dgst[i + 1] = sha1_hmac_ctx2.opad.h[1];
    tmps[gid].dgst[i + 2] = sha1_hmac_ctx2.opad.h[2];
    tmps[gid].dgst[i + 3] = sha1_hmac_ctx2.opad.h[3];
    tmps[gid].dgst[i + 4] = sha1_hmac_ctx2.opad.h[4];

    tmps[gid].out[i + 0] = tmps[gid].dgst[i + 0];
    tmps[gid].out[i + 1] = tmps[gid].dgst[i + 1];
    tmps[gid].out[i + 2] = tmps[gid].dgst[i + 2];
    tmps[gid].out[i + 3] = tmps[gid].dgst[i + 3];
    tmps[gid].out[i + 4] = tmps[gid].dgst[i + 4];
  }
}

__kernel void m02500_loop (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global wpa_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const wpa_t *wpa_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  const u32 gid = get_global_id (0);

  if ((gid * VECT_SIZE) >= gid_max) return;

  u32x ipad[5];
  u32x opad[5];

  ipad[0] = packv (tmps, ipad, gid, 0);
  ipad[1] = packv (tmps, ipad, gid, 1);
  ipad[2] = packv (tmps, ipad, gid, 2);
  ipad[3] = packv (tmps, ipad, gid, 3);
  ipad[4] = packv (tmps, ipad, gid, 4);

  opad[0] = packv (tmps, opad, gid, 0);
  opad[1] = packv (tmps, opad, gid, 1);
  opad[2] = packv (tmps, opad, gid, 2);
  opad[3] = packv (tmps, opad, gid, 3);
  opad[4] = packv (tmps, opad, gid, 4);

  for (u32 i = 0; i < 8; i += 5)
  {
    u32x dgst[5];
    u32x out[5];

    dgst[0] = packv (tmps, dgst, gid, i + 0);
    dgst[1] = packv (tmps, dgst, gid, i + 1);
    dgst[2] = packv (tmps, dgst, gid, i + 2);
    dgst[3] = packv (tmps, dgst, gid, i + 3);
    dgst[4] = packv (tmps, dgst, gid, i + 4);

    out[0] = packv (tmps, out, gid, i + 0);
    out[1] = packv (tmps, out, gid, i + 1);
    out[2] = packv (tmps, out, gid, i + 2);
    out[3] = packv (tmps, out, gid, i + 3);
    out[4] = packv (tmps, out, gid, i + 4);

    for (u32 j = 0; j < loop_cnt; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];

      w0[0] = dgst[0];
      w0[1] = dgst[1];
      w0[2] = dgst[2];
      w0[3] = dgst[3];
      w1[0] = dgst[4];
      w1[1] = 0x80000000;
      w1[2] = 0;
      w1[3] = 0;
      w2[0] = 0;
      w2[1] = 0;
      w2[2] = 0;
      w2[3] = 0;
      w3[0] = 0;
      w3[1] = 0;
      w3[2] = 0;
      w3[3] = (64 + 20) * 8;

      hmac_sha1_run_V (w0, w1, w2, w3, ipad, opad, dgst);

      out[0] ^= dgst[0];
      out[1] ^= dgst[1];
      out[2] ^= dgst[2];
      out[3] ^= dgst[3];
      out[4] ^= dgst[4];
    }

    unpackv (tmps, dgst, gid, i + 0, dgst[0]);
    unpackv (tmps, dgst, gid, i + 1, dgst[1]);
    unpackv (tmps, dgst, gid, i + 2, dgst[2]);
    unpackv (tmps, dgst, gid, i + 3, dgst[3]);
    unpackv (tmps, dgst, gid, i + 4, dgst[4]);

    unpackv (tmps, out, gid, i + 0, out[0]);
    unpackv (tmps, out, gid, i + 1, out[1]);
    unpackv (tmps, out, gid, i + 2, out[2]);
    unpackv (tmps, out, gid, i + 3, out[3]);
    unpackv (tmps, out, gid, i + 4, out[4]);
  }
}

__kernel void m02500_comp (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global wpa_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const wpa_t *wpa_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 out[8];

  out[0] = tmps[gid].out[0];
  out[1] = tmps[gid].out[1];
  out[2] = tmps[gid].out[2];
  out[3] = tmps[gid].out[3];
  out[4] = tmps[gid].out[4];
  out[5] = tmps[gid].out[5];
  out[6] = tmps[gid].out[6];
  out[7] = tmps[gid].out[7];

  const u32 lid = get_local_id (0);

  const u32 digest_pos = loop_pos;

  const u32 digest_cur = digests_offset + digest_pos;

  __global const wpa_t *wpa = &wpa_bufs[digest_cur];

  u32 pke[32];

  pke[ 0] = wpa->pke[ 0];
  pke[ 1] = wpa->pke[ 1];
  pke[ 2] = wpa->pke[ 2];
  pke[ 3] = wpa->pke[ 3];
  pke[ 4] = wpa->pke[ 4];
  pke[ 5] = wpa->pke[ 5];
  pke[ 6] = wpa->pke[ 6];
  pke[ 7] = wpa->pke[ 7];
  pke[ 8] = wpa->pke[ 8];
  pke[ 9] = wpa->pke[ 9];
  pke[10] = wpa->pke[10];
  pke[11] = wpa->pke[11];
  pke[12] = wpa->pke[12];
  pke[13] = wpa->pke[13];
  pke[14] = wpa->pke[14];
  pke[15] = wpa->pke[15];
  pke[16] = wpa->pke[16];
  pke[17] = wpa->pke[17];
  pke[18] = wpa->pke[18];
  pke[19] = wpa->pke[19];
  pke[20] = wpa->pke[20];
  pke[21] = wpa->pke[21];
  pke[22] = wpa->pke[22];
  pke[23] = wpa->pke[23];
  pke[24] = wpa->pke[24];
  pke[25] = 0;
  pke[26] = 0;
  pke[27] = 0;
  pke[28] = 0;
  pke[29] = 0;
  pke[30] = 0;
  pke[31] = 0;

  u32 to;

  if (wpa->nonce_compare < 0)
  {
    to = pke[15] << 24
       | pke[16] >>  8;
  }
  else
  {
    to = pke[23] << 24
       | pke[24] >>  8;
  }

  const u32 nonce_error_corrections = wpa->nonce_error_corrections;

  for (u32 nonce_error_correction = 0; nonce_error_correction <= nonce_error_corrections; nonce_error_correction++)
  {
    u32 t = to;

    t = swap32_S (t);

    t -= nonce_error_corrections / 2;
    t += nonce_error_correction;

    t = swap32_S (t);

    if (wpa->nonce_compare < 0)
    {
      pke[15] = (pke[15] & ~0x000000ff) | (t >> 24);
      pke[16] = (pke[16] & ~0xffffff00) | (t <<  8);
    }
    else
    {
      pke[23] = (pke[23] & ~0x000000ff) | (t >> 24);
      pke[24] = (pke[24] & ~0xffffff00) | (t <<  8);
    }

    u32 w0[4];
    u32 w1[4];
    u32 w2[4];
    u32 w3[4];

    w0[0] = out[0];
    w0[1] = out[1];
    w0[2] = out[2];
    w0[3] = out[3];
    w1[0] = out[4];
    w1[1] = out[5];
    w1[2] = out[6];
    w1[3] = out[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    sha1_hmac_ctx_t ctx1;

    sha1_hmac_init (&ctx1, w0, w1, w2, w3);

    sha1_hmac_update (&ctx1, pke, 100);

    sha1_hmac_final (&ctx1);

    u32 digest[4];

    digest[0] = ctx1.opad.h[0];
    digest[1] = ctx1.opad.h[1];
    digest[2] = ctx1.opad.h[2];
    digest[3] = ctx1.opad.h[3];

    if (wpa->keyver == 1)
    {
      u32 t0[4];
      u32 t1[4];
      u32 t2[4];
      u32 t3[4];

      t0[0] = swap32_S (digest[0]);
      t0[1] = swap32_S (digest[1]);
      t0[2] = swap32_S (digest[2]);
      t0[3] = swap32_S (digest[3]);
      t1[0] = 0;
      t1[1] = 0;
      t1[2] = 0;
      t1[3] = 0;
      t2[0] = 0;
      t2[1] = 0;
      t2[2] = 0;
      t2[3] = 0;
      t3[0] = 0;
      t3[1] = 0;
      t3[2] = 0;
      t3[3] = 0;

      md5_hmac_ctx_t ctx2;

      md5_hmac_init (&ctx2, t0, t1, t2, t3);

      md5_hmac_update_global (&ctx2, wpa->eapol, wpa->eapol_len);

      md5_hmac_final (&ctx2);

      digest[0] = ctx2.opad.h[0];
      digest[1] = ctx2.opad.h[1];
      digest[2] = ctx2.opad.h[2];
      digest[3] = ctx2.opad.h[3];
    }
    else
    {
      u32 t0[4];
      u32 t1[4];
      u32 t2[4];
      u32 t3[4];

      t0[0] = digest[0];
      t0[1] = digest[1];
      t0[2] = digest[2];
      t0[3] = digest[3];
      t1[0] = 0;
      t1[1] = 0;
      t1[2] = 0;
      t1[3] = 0;
      t2[0] = 0;
      t2[1] = 0;
      t2[2] = 0;
      t2[3] = 0;
      t3[0] = 0;
      t3[1] = 0;
      t3[2] = 0;
      t3[3] = 0;

      sha1_hmac_ctx_t ctx2;

      sha1_hmac_init (&ctx2, t0, t1, t2, t3);

      sha1_hmac_update_global (&ctx2, wpa->eapol, wpa->eapol_len);

      sha1_hmac_final (&ctx2);

      digest[0] = ctx2.opad.h[0];
      digest[1] = ctx2.opad.h[1];
      digest[2] = ctx2.opad.h[2];
      digest[3] = ctx2.opad.h[3];
    }

    /**
     * final compare
     */

    if ((digest[0] == wpa->keymic[0])
     && (digest[1] == wpa->keymic[1])
     && (digest[2] == wpa->keymic[2])
     && (digest[3] == wpa->keymic[3]))
    {
      if (atomic_inc (&hashes_shown[digest_cur]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, digest_pos, digest_cur, gid, 0);
      }
    }
  }

  // the same code again, but with BE order for the t++

  for (u32 nonce_error_correction = 0; nonce_error_correction <= nonce_error_corrections; nonce_error_correction++)
  {
    u32 t = to;

    t -= nonce_error_corrections / 2;
    t += nonce_error_correction;

    if (t == to) continue; // we already had this checked in the LE loop

    if (wpa->nonce_compare < 0)
    {
      pke[15] = (pke[15] & ~0x000000ff) | (t >> 24);
      pke[16] = (pke[16] & ~0xffffff00) | (t <<  8);
    }
    else
    {
      pke[23] = (pke[23] & ~0x000000ff) | (t >> 24);
      pke[24] = (pke[24] & ~0xffffff00) | (t <<  8);
    }

    u32 w0[4];
    u32 w1[4];
    u32 w2[4];
    u32 w3[4];

    w0[0] = out[0];
    w0[1] = out[1];
    w0[2] = out[2];
    w0[3] = out[3];
    w1[0] = out[4];
    w1[1] = out[5];
    w1[2] = out[6];
    w1[3] = out[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    sha1_hmac_ctx_t ctx1;

    sha1_hmac_init (&ctx1, w0, w1, w2, w3);

    sha1_hmac_update (&ctx1, pke, 100);

    sha1_hmac_final (&ctx1);

    u32 digest[4];

    digest[0] = ctx1.opad.h[0];
    digest[1] = ctx1.opad.h[1];
    digest[2] = ctx1.opad.h[2];
    digest[3] = ctx1.opad.h[3];

    if (wpa->keyver == 1)
    {
      u32 t0[4];
      u32 t1[4];
      u32 t2[4];
      u32 t3[4];

      t0[0] = swap32_S (digest[0]);
      t0[1] = swap32_S (digest[1]);
      t0[2] = swap32_S (digest[2]);
      t0[3] = swap32_S (digest[3]);
      t1[0] = 0;
      t1[1] = 0;
      t1[2] = 0;
      t1[3] = 0;
      t2[0] = 0;
      t2[1] = 0;
      t2[2] = 0;
      t2[3] = 0;
      t3[0] = 0;
      t3[1] = 0;
      t3[2] = 0;
      t3[3] = 0;

      md5_hmac_ctx_t ctx2;

      md5_hmac_init (&ctx2, t0, t1, t2, t3);

      md5_hmac_update_global (&ctx2, wpa->eapol, wpa->eapol_len);

      md5_hmac_final (&ctx2);

      digest[0] = ctx2.opad.h[0];
      digest[1] = ctx2.opad.h[1];
      digest[2] = ctx2.opad.h[2];
      digest[3] = ctx2.opad.h[3];
    }
    else
    {
      u32 t0[4];
      u32 t1[4];
      u32 t2[4];
      u32 t3[4];

      t0[0] = digest[0];
      t0[1] = digest[1];
      t0[2] = digest[2];
      t0[3] = digest[3];
      t1[0] = 0;
      t1[1] = 0;
      t1[2] = 0;
      t1[3] = 0;
      t2[0] = 0;
      t2[1] = 0;
      t2[2] = 0;
      t2[3] = 0;
      t3[0] = 0;
      t3[1] = 0;
      t3[2] = 0;
      t3[3] = 0;

      sha1_hmac_ctx_t ctx2;

      sha1_hmac_init (&ctx2, t0, t1, t2, t3);

      sha1_hmac_update_global (&ctx2, wpa->eapol, wpa->eapol_len);

      sha1_hmac_final (&ctx2);

      digest[0] = ctx2.opad.h[0];
      digest[1] = ctx2.opad.h[1];
      digest[2] = ctx2.opad.h[2];
      digest[3] = ctx2.opad.h[3];
    }

    /**
     * final compare
     */

    if ((digest[0] == wpa->keymic[0])
     && (digest[1] == wpa->keymic[1])
     && (digest[2] == wpa->keymic[2])
     && (digest[3] == wpa->keymic[3]))
    {
      if (atomic_inc (&hashes_shown[digest_cur]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, digest_pos, digest_cur, gid, 0);
      }
    }
  }
}
