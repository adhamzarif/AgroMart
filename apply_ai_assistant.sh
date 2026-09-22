#!/usr/bin/env bash
# AgroMart — Gemini AI assistant for farmer dashboard.
# Run from ~/Documents/AgroMart:  bash apply_ai_assistant.sh
set -euo pipefail
[ -d backend/src ] || { echo "ERROR: run from ~/Documents/AgroMart"; exit 1; }
say(){ echo "  $*"; }
PY="$(command -v python3 || command -v python || true)"
export PYTHONUTF8=1

mkdir -p backend/src/controllers backend/src/routes \
         frontend/src/components/ui frontend/src/pages/farmer

echo "==> [1/5] Writing files..."
echo 'Ly8gYWkuY29udHJvbGxlci5qcyDigJQgR2VtaW5pIEFJIHByb3h5IGZvciB0aGUgZmFybWVyIGFzc2lzdGFudC4KLy8gTmV2ZXIgZXhwb3NlIHRoZSBBUEkga2V5IHRvIHRoZSBmcm9udGVuZDsgYWxsIHJlcXVlc3RzIGNvbWUgdGhyb3VnaCBoZXJlLgppbXBvcnQgeyBHb29nbGVHZW5lcmF0aXZlQUkgfSBmcm9tICdAZ29vZ2xlL2dlbmVyYXRpdmUtYWknOwppbXBvcnQgZnMgZnJvbSAnZnMnOwoKY29uc3QgU1lTVEVNX1BST01QVCA9IGBZb3UgYXJlIGFuIEFJIGFzc2lzdGFudCBmb3IgQWdyb01hcnQsIGEgQmFuZ2xhZGVzaGkgYWdyaWN1bHR1cmFsIG1hcmtldHBsYWNlLgpZb3VyIHVzZXJzIGFyZSBmYXJtZXJzLCBidXllcnMsIGFuZCBhZ2VudHMuCgpZb3VyIGpvYjoKLSBIZWxwIGZhcm1lcnMgd2l0aCBjcm9wIGFkdmljZSAodmFyaWV0aWVzLCBwbGFudGluZywgaGFydmVzdGluZywgY2FyZSkKLSBJZGVudGlmeSBjcm9wIGRpc2Vhc2VzIGZyb20gcGhvdG9zCi0gQW5zd2VyIHF1ZXN0aW9ucyBhYm91dCBtYXJrZXQgcHJpY2VzLCB3ZWF0aGVyLCBhbmQgYmVzdCBwcmFjdGljZXMKLSBFeHBsYWluIGhvdyBBZ3JvTWFydCBmZWF0dXJlcyB3b3JrIChsaXN0aW5nIGNyb3BzLCBwcmljaW5nLCBkZWxpdmVyeSkKLSBTdWdnZXN0IHdoaWNoIGNyb3BzIHRvIGdyb3cgYmFzZWQgb24gc2Vhc29uLCByZWdpb24sIG9yIG1hcmtldCBkZW1hbmQKLSBBbnN3ZXIgaW4gYSB3YXJtLCByZXNwZWN0ZnVsLCBlbmNvdXJhZ2luZyB0b25lIOKAlCBtYW55IHVzZXJzIGFyZSBydXJhbCBmYXJtZXJzIHdobyBtYXkgbm90IGhhdmUgdGVjaG5pY2FsIGJhY2tncm91bmRzCgpMYW5ndWFnZSBydWxlOiBSZXBseSBpbiB0aGUgc2FtZSBsYW5ndWFnZSB0aGUgdXNlciB3cml0ZXMgaW4uCi0gSWYgdGhleSB3cml0ZSBpbiBCZW5nYWxpICjgpqzgpr7gpoLgprLgpr4pLCByZXBseSBpbiBCZW5nYWxpLgotIElmIHRoZXkgd3JpdGUgaW4gRW5nbGlzaCwgcmVwbHkgaW4gRW5nbGlzaC4KLSBJZiBtaXhlZCwgZGVmYXVsdCB0byBCZW5nYWxpLgoKS2VlcCBhbnN3ZXJzIHByYWN0aWNhbCwgc2hvcnQsIGFuZCBhY3Rpb25hYmxlLiBVc2Ugc2ltcGxlIHdvcmRzLiBOdW1iZXIgeW91ciBzdGVwcyB3aGVuIGdpdmluZyBpbnN0cnVjdGlvbnMuYDsKCmxldCBnZW5BSSA9IG51bGw7CmZ1bmN0aW9uIGdldE1vZGVsKCkgewogIGlmICghcHJvY2Vzcy5lbnYuR0VNSU5JX0FQSV9LRVkpIHsKICAgIHRocm93IG5ldyBFcnJvcignR0VNSU5JX0FQSV9LRVkgaXMgbm90IHNldCBpbiBiYWNrZW5kLy5lbnYnKTsKICB9CiAgaWYgKCFnZW5BSSkgZ2VuQUkgPSBuZXcgR29vZ2xlR2VuZXJhdGl2ZUFJKHByb2Nlc3MuZW52LkdFTUlOSV9BUElfS0VZKTsKICByZXR1cm4gZ2VuQUkuZ2V0R2VuZXJhdGl2ZU1vZGVsKHsKICAgIG1vZGVsOiAnZ2VtaW5pLTEuNS1mbGFzaCcsCiAgICBzeXN0ZW1JbnN0cnVjdGlvbjogU1lTVEVNX1BST01QVCwKICB9KTsKfQoKZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGNoYXQocmVxLCByZXMsIG5leHQpIHsKICB0cnkgewogICAgY29uc3QgbWVzc2FnZSA9IFN0cmluZyhyZXEuYm9keS5tZXNzYWdlIHx8ICcnKS50cmltKCk7CiAgICBjb25zdCBoaXN0b3J5ID0gcmVxLmJvZHkuaGlzdG9yeSA/IEpTT04ucGFyc2UocmVxLmJvZHkuaGlzdG9yeSkgOiBbXTsKCiAgICBpZiAoIW1lc3NhZ2UgJiYgIXJlcS5maWxlKSB7CiAgICAgIHJldHVybiByZXMuc3RhdHVzKDQwMCkuanNvbih7IGVycm9yOiAnTWVzc2FnZSBvciBpbWFnZSByZXF1aXJlZCcgfSk7CiAgICB9CgogICAgY29uc3QgbW9kZWwgPSBnZXRNb2RlbCgpOwoKICAgIC8vIEJ1aWxkIHRoZSBjdXJyZW50IHR1cm4ncyBjb250ZW50CiAgICBjb25zdCBwYXJ0cyA9IFtdOwogICAgaWYgKG1lc3NhZ2UpIHBhcnRzLnB1c2goeyB0ZXh0OiBtZXNzYWdlIH0pOwoKICAgIGlmIChyZXEuZmlsZSkgewogICAgICBjb25zdCBmaWxlQnl0ZXMgPSBmcy5yZWFkRmlsZVN5bmMocmVxLmZpbGUucGF0aCk7CiAgICAgIHBhcnRzLnB1c2goewogICAgICAgIGlubGluZURhdGE6IHsKICAgICAgICAgIG1pbWVUeXBlOiByZXEuZmlsZS5taW1ldHlwZSwKICAgICAgICAgIGRhdGE6IGZpbGVCeXRlcy50b1N0cmluZygnYmFzZTY0JyksCiAgICAgICAgfSwKICAgICAgfSk7CiAgICB9CgogICAgLy8gQ29udmVydCBtZXNzYWdlIGhpc3RvcnkgdG8gR2VtaW5pJ3MgZm9ybWF0IChhbHRlcm5hdGluZyB1c2VyL21vZGVsKQogICAgY29uc3QgZ2VtaW5pSGlzdG9yeSA9IGhpc3RvcnkKICAgICAgLmZpbHRlcigoaCkgPT4gaC5yb2xlID09PSAndXNlcicgfHwgaC5yb2xlID09PSAnYXNzaXN0YW50JykKICAgICAgLm1hcCgoaCkgPT4gKHsKICAgICAgICByb2xlOiBoLnJvbGUgPT09ICdhc3Npc3RhbnQnID8gJ21vZGVsJyA6ICd1c2VyJywKICAgICAgICBwYXJ0czogW3sgdGV4dDogaC50ZXh0IHx8ICcnIH1dLAogICAgICB9KSk7CgogICAgLy8gU3RhcnQgYSBjaGF0IHdpdGggaGlzdG9yeSBmb3IgY29udGV4dAogICAgY29uc3QgY2hhdFNlc3Npb24gPSBtb2RlbC5zdGFydENoYXQoeyBoaXN0b3J5OiBnZW1pbmlIaXN0b3J5IH0pOwoKICAgIGNvbnN0IHJlc3VsdCA9IGF3YWl0IGNoYXRTZXNzaW9uLnNlbmRNZXNzYWdlKHBhcnRzKTsKICAgIGNvbnN0IHJlc3BvbnNlVGV4dCA9IHJlc3VsdC5yZXNwb25zZS50ZXh0KCk7CgogICAgLy8gQ2xlYW4gdXAgdXBsb2FkZWQgdGVtcCBmaWxlCiAgICBpZiAocmVxLmZpbGUpIHsKICAgICAgdHJ5IHsgZnMudW5saW5rU3luYyhyZXEuZmlsZS5wYXRoKTsgfSBjYXRjaCB7fQogICAgfQoKICAgIHJlcy5qc29uKHsgcmVwbHk6IHJlc3BvbnNlVGV4dCB9KTsKICB9IGNhdGNoIChlcnIpIHsKICAgIC8vIENsZWFuIHVwIHRlbXAgZmlsZSBvbiBlcnJvcgogICAgaWYgKHJlcS5maWxlKSB7CiAgICAgIHRyeSB7IGZzLnVubGlua1N5bmMocmVxLmZpbGUucGF0aCk7IH0gY2F0Y2gge30KICAgIH0KICAgIGNvbnNvbGUuZXJyb3IoJ0FJIGNoYXQgZXJyb3I6JywgZXJyLm1lc3NhZ2UpOwogICAgaWYgKGVyci5tZXNzYWdlLmluY2x1ZGVzKCdHRU1JTklfQVBJX0tFWScpKSB7CiAgICAgIHJldHVybiByZXMuc3RhdHVzKDUwMCkuanNvbih7IGVycm9yOiAnQUkgc2VydmljZSBub3QgY29uZmlndXJlZC4gQ29udGFjdCBhZG1pbmlzdHJhdG9yLicgfSk7CiAgICB9CiAgICBpZiAoZXJyLm1lc3NhZ2UuaW5jbHVkZXMoJ0FQSV9LRVlfSU5WQUxJRCcpIHx8IGVyci5zdGF0dXMgPT09IDQwMCkgewogICAgICByZXR1cm4gcmVzLnN0YXR1cyg1MDApLmpzb24oeyBlcnJvcjogJ0FJIHNlcnZpY2UgYXV0aGVudGljYXRpb24gZmFpbGVkLicgfSk7CiAgICB9CiAgICBpZiAoZXJyLnN0YXR1cyA9PT0gNDI5IHx8IGVyci5tZXNzYWdlLmluY2x1ZGVzKCdxdW90YScpKSB7CiAgICAgIHJldHVybiByZXMuc3RhdHVzKDQyOSkuanNvbih7IGVycm9yOiAnQUkgaXMgYnVzeSByaWdodCBub3cuIFBsZWFzZSB0cnkgYWdhaW4gaW4gYSBtb21lbnQuJyB9KTsKICAgIH0KICAgIHJlcy5zdGF0dXMoNTAwKS5qc29uKHsgZXJyb3I6ICdBSSBmYWlsZWQgdG8gcmVzcG9uZC4gUGxlYXNlIHRyeSBhZ2Fpbi4nIH0pOwogIH0KfQo=' | base64 -d > 'backend/src/controllers/ai.controller.js' && say 'wrote backend/src/controllers/ai.controller.js'
echo 'Ly8gYWkucm91dGVzLmpzIOKAlCAvYXBpL2FpLyoKaW1wb3J0IHsgUm91dGVyIH0gZnJvbSAnZXhwcmVzcyc7CmltcG9ydCBtdWx0ZXIgZnJvbSAnbXVsdGVyJzsKaW1wb3J0IHBhdGggZnJvbSAncGF0aCc7CmltcG9ydCB7IGZpbGVVUkxUb1BhdGggfSBmcm9tICd1cmwnOwppbXBvcnQgeyBjaGF0IH0gZnJvbSAnLi4vY29udHJvbGxlcnMvYWkuY29udHJvbGxlci5qcyc7CmltcG9ydCB7IHJlcXVpcmVSb2xlIH0gZnJvbSAnLi4vbWlkZGxld2FyZS9hdXRoLm1pZGRsZXdhcmUuanMnOwoKY29uc3QgX19iMmRpciA9IHBhdGguZGlybmFtZShmaWxlVVJMVG9QYXRoKGltcG9ydC5tZXRhLnVybCkpOwoKLy8gU3RvcmUgdXBsb2FkZWQgY2hhdCBpbWFnZXMgdGVtcG9yYXJpbHkgKGNsZWFuZWQgdXAgYWZ0ZXIgR2VtaW5pIGNhbGwpCmNvbnN0IHVwbG9hZCA9IG11bHRlcih7CiAgZGVzdDogcGF0aC5yZXNvbHZlKF9fYjJkaXIsICcuLi9zdG9yYWdlL3VwbG9hZHMvYWktdG1wJyksCiAgbGltaXRzOiB7IGZpbGVTaXplOiA0ICogMTAyNCAqIDEwMjQgfSwgLy8gNE1CIHBlciBpbWFnZQogIGZpbGVGaWx0ZXI6IChfcmVxLCBmaWxlLCBjYikgPT4gewogICAgaWYgKFsnaW1hZ2UvanBlZycsICdpbWFnZS9wbmcnLCAnaW1hZ2Uvd2VicCddLmluY2x1ZGVzKGZpbGUubWltZXR5cGUpKSB7CiAgICAgIGNiKG51bGwsIHRydWUpOwogICAgfSBlbHNlIHsKICAgICAgY2IobmV3IEVycm9yKCdPbmx5IEpQRywgUE5HLCBvciBXRUJQIGltYWdlcycpKTsKICAgIH0KICB9LAp9KTsKCmNvbnN0IHJvdXRlciA9IFJvdXRlcigpOwoKcm91dGVyLnBvc3QoCiAgJy9jaGF0JywKICByZXF1aXJlUm9sZSgnZmFybWVyJywgJ2FkbWluJyksCiAgdXBsb2FkLnNpbmdsZSgnaW1hZ2UnKSwKICBjaGF0Cik7CgpleHBvcnQgZGVmYXVsdCByb3V0ZXI7Cg==' | base64 -d > 'backend/src/routes/ai.routes.js' && say 'wrote backend/src/routes/ai.routes.js'
echo 'Ly8gQWlDaGF0RHJhd2VyLmpzeCDigJQgc2xpZGUtaW4gY2hhdCBwYW5lbCBmb3IgdGhlIGZhcm1lciBBSSBhc3Npc3RhbnQuCmltcG9ydCB7IHVzZVN0YXRlLCB1c2VSZWYsIHVzZUVmZmVjdCB9IGZyb20gJ3JlYWN0JzsKaW1wb3J0IHsgdXNlTGFuZyB9IGZyb20gJy4uLy4uL2NvbnRleHQvTGFuZ0NvbnRleHQuanN4JzsKCmNvbnN0IEJBU0UgPSBpbXBvcnQubWV0YS5lbnYuVklURV9BUElfVVJMIHx8ICdodHRwOi8vbG9jYWxob3N0OjQwMDAnOwoKZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gQWlDaGF0RHJhd2VyKHsgb3Blbiwgb25DbG9zZSB9KSB7CiAgY29uc3QgeyB0LCBsYW5nIH0gPSB1c2VMYW5nKCk7CiAgY29uc3QgW21lc3NhZ2VzLCBzZXRNZXNzYWdlc10gPSB1c2VTdGF0ZShbXSk7CiAgY29uc3QgW2lucHV0LCBzZXRJbnB1dF0gPSB1c2VTdGF0ZSgnJyk7CiAgY29uc3QgW2ltYWdlLCBzZXRJbWFnZV0gPSB1c2VTdGF0ZShudWxsKTsKICBjb25zdCBbaW1hZ2VQcmV2aWV3LCBzZXRJbWFnZVByZXZpZXddID0gdXNlU3RhdGUoJycpOwogIGNvbnN0IFtidXN5LCBzZXRCdXN5XSA9IHVzZVN0YXRlKGZhbHNlKTsKICBjb25zdCBbZXJyb3IsIHNldEVycm9yXSA9IHVzZVN0YXRlKG51bGwpOwogIGNvbnN0IGJvdHRvbVJlZiA9IHVzZVJlZihudWxsKTsKICBjb25zdCBmaWxlSW5wdXRSZWYgPSB1c2VSZWYobnVsbCk7CgogIHVzZUVmZmVjdCgoKSA9PiB7CiAgICBpZiAob3BlbikgYm90dG9tUmVmLmN1cnJlbnQ/LnNjcm9sbEludG9WaWV3KHsgYmVoYXZpb3I6ICdzbW9vdGgnIH0pOwogIH0sIFttZXNzYWdlcywgb3Blbl0pOwoKICB1c2VFZmZlY3QoKCkgPT4gewogICAgLy8gcmVzZXQgcHJldmlldyBVUkwgd2hlbiBpbWFnZSBjaGFuZ2VzCiAgICByZXR1cm4gKCkgPT4gaW1hZ2VQcmV2aWV3ICYmIFVSTC5yZXZva2VPYmplY3RVUkwoaW1hZ2VQcmV2aWV3KTsKICB9LCBbaW1hZ2VQcmV2aWV3XSk7CgogIGZ1bmN0aW9uIHBpY2tJbWFnZShlKSB7CiAgICBjb25zdCBmaWxlID0gZS50YXJnZXQuZmlsZXM/LlswXTsKICAgIGlmICghZmlsZSkgcmV0dXJuOwogICAgaWYgKGZpbGUuc2l6ZSA+IDQgKiAxMDI0ICogMTAyNCkgewogICAgICBzZXRFcnJvcih0KCdhaV9pbWFnZV90b29fYmlnJykpOwogICAgICByZXR1cm47CiAgICB9CiAgICBzZXRJbWFnZShmaWxlKTsKICAgIGlmIChpbWFnZVByZXZpZXcpIFVSTC5yZXZva2VPYmplY3RVUkwoaW1hZ2VQcmV2aWV3KTsKICAgIHNldEltYWdlUHJldmlldyhVUkwuY3JlYXRlT2JqZWN0VVJMKGZpbGUpKTsKICAgIHNldEVycm9yKG51bGwpOwogIH0KCiAgZnVuY3Rpb24gcmVtb3ZlSW1hZ2UoKSB7CiAgICBpZiAoaW1hZ2VQcmV2aWV3KSBVUkwucmV2b2tlT2JqZWN0VVJMKGltYWdlUHJldmlldyk7CiAgICBzZXRJbWFnZShudWxsKTsKICAgIHNldEltYWdlUHJldmlldygnJyk7CiAgICBpZiAoZmlsZUlucHV0UmVmLmN1cnJlbnQpIGZpbGVJbnB1dFJlZi5jdXJyZW50LnZhbHVlID0gJyc7CiAgfQoKICBhc3luYyBmdW5jdGlvbiBzZW5kKCkgewogICAgY29uc3QgdGV4dCA9IGlucHV0LnRyaW0oKTsKICAgIGlmICghdGV4dCAmJiAhaW1hZ2UpIHJldHVybjsKICAgIGlmIChidXN5KSByZXR1cm47CgogICAgc2V0RXJyb3IobnVsbCk7CiAgICBzZXRCdXN5KHRydWUpOwoKICAgIGNvbnN0IHVzZXJNc2cgPSB7IHJvbGU6ICd1c2VyJywgdGV4dCwgaW1hZ2U6IGltYWdlUHJldmlldyB9OwogICAgY29uc3QgbmV4dE1lc3NhZ2VzID0gWy4uLm1lc3NhZ2VzLCB1c2VyTXNnXTsKICAgIHNldE1lc3NhZ2VzKG5leHRNZXNzYWdlcyk7CiAgICBzZXRJbnB1dCgnJyk7CgogICAgdHJ5IHsKICAgICAgY29uc3QgZmQgPSBuZXcgRm9ybURhdGEoKTsKICAgICAgZmQuYXBwZW5kKCdtZXNzYWdlJywgdGV4dCk7CiAgICAgIC8vIFNlbmQgaGlzdG9yeSBmb3IgY29udGV4dCAoZXhjbHVkaW5nIHRoZSBqdXN0LWFkZGVkIHVzZXIgbWVzc2FnZSkKICAgICAgZmQuYXBwZW5kKAogICAgICAgICdoaXN0b3J5JywKICAgICAgICBKU09OLnN0cmluZ2lmeShtZXNzYWdlcy5tYXAoKG0pID0+ICh7IHJvbGU6IG0ucm9sZSwgdGV4dDogbS50ZXh0IH0pKSkKICAgICAgKTsKICAgICAgaWYgKGltYWdlKSBmZC5hcHBlbmQoJ2ltYWdlJywgaW1hZ2UpOwoKICAgICAgY29uc3QgcmVzID0gYXdhaXQgZmV0Y2goYCR7QkFTRX0vYXBpL2FpL2NoYXRgLCB7CiAgICAgICAgbWV0aG9kOiAnUE9TVCcsCiAgICAgICAgY3JlZGVudGlhbHM6ICdpbmNsdWRlJywKICAgICAgICBib2R5OiBmZCwKICAgICAgfSk7CiAgICAgIGNvbnN0IGRhdGEgPSBhd2FpdCByZXMuanNvbigpOwogICAgICBpZiAoIXJlcy5vaykgdGhyb3cgbmV3IEVycm9yKGRhdGEuZXJyb3IgfHwgYEhUVFAgJHtyZXMuc3RhdHVzfWApOwoKICAgICAgc2V0TWVzc2FnZXMoWy4uLm5leHRNZXNzYWdlcywgeyByb2xlOiAnYXNzaXN0YW50JywgdGV4dDogZGF0YS5yZXBseSB9XSk7CiAgICAgIHJlbW92ZUltYWdlKCk7CiAgICB9IGNhdGNoIChlcnIpIHsKICAgICAgc2V0RXJyb3IoZXJyLm1lc3NhZ2UpOwogICAgICAvLyByZW1vdmUgdGhlIG9wdGltaXN0aWMgdXNlciBtZXNzYWdlIG9uIGZhaWx1cmUgc28gdGhleSBjYW4gcmV0cnkKICAgICAgc2V0TWVzc2FnZXMobWVzc2FnZXMpOwogICAgICBzZXRJbnB1dCh0ZXh0KTsKICAgIH0gZmluYWxseSB7CiAgICAgIHNldEJ1c3koZmFsc2UpOwogICAgfQogIH0KCiAgZnVuY3Rpb24gb25LZXkoZSkgewogICAgaWYgKGUua2V5ID09PSAnRW50ZXInICYmICFlLnNoaWZ0S2V5KSB7CiAgICAgIGUucHJldmVudERlZmF1bHQoKTsKICAgICAgc2VuZCgpOwogICAgfQogIH0KCiAgaWYgKCFvcGVuKSByZXR1cm4gbnVsbDsKCiAgcmV0dXJuICgKICAgIDw+CiAgICAgIHsvKiBiYWNrZHJvcCAqL30KICAgICAgPGRpdgogICAgICAgIGNsYXNzTmFtZT0iZml4ZWQgaW5zZXQtMCB6LVs5MDBdIGJnLWJsYWNrLzQwIgogICAgICAgIG9uQ2xpY2s9e29uQ2xvc2V9CiAgICAgIC8+CiAgICAgIHsvKiBkcmF3ZXIgKi99CiAgICAgIDxhc2lkZQogICAgICAgIGNsYXNzTmFtZT0iZml4ZWQgcmlnaHQtMCB0b3AtMCB6LVs5MDFdIGZsZXggaC1mdWxsIHctZnVsbCBtYXgtdy1tZCBmbGV4LWNvbCBiZy13aGl0ZSBzaGFkb3ctMnhsIgogICAgICAgIHN0eWxlPXt7IGFuaW1hdGlvbjogJ3NsaWRlaW4gMC4yNXMgZWFzZS1vdXQnIH19CiAgICAgID4KICAgICAgICA8c3R5bGU+e2BAa2V5ZnJhbWVzIHNsaWRlaW4geyBmcm9tIHsgdHJhbnNmb3JtOiB0cmFuc2xhdGVYKDEwMCUpOyB9IHRvIHsgdHJhbnNmb3JtOiB0cmFuc2xhdGVYKDApOyB9IH1gfTwvc3R5bGU+CgogICAgICAgIHsvKiBIZWFkZXIgKi99CiAgICAgICAgPGhlYWRlciBjbGFzc05hbWU9ImZsZXggaXRlbXMtY2VudGVyIGp1c3RpZnktYmV0d2VlbiBiZy1ncmFkaWVudC10by1iciBmcm9tLW0xLWRhcmsgdG8tbTEgcHgtNCBweS0zIHRleHQtd2hpdGUiPgogICAgICAgICAgPGRpdiBjbGFzc05hbWU9ImZsZXggaXRlbXMtY2VudGVyIGdhcC0yIj4KICAgICAgICAgICAgPHNwYW4gY2xhc3NOYW1lPSJ0ZXh0LTJ4bCI+8J+kljwvc3Bhbj4KICAgICAgICAgICAgPGRpdj4KICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iZm9udC1ib2xkIj57dCgnYWlfdGl0bGUnKX08L2Rpdj4KICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0idGV4dC14cyB0ZXh0LXdoaXRlLzgwIj57dCgnYWlfc3VidGl0bGUnKX08L2Rpdj4KICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICA8L2Rpdj4KICAgICAgICAgIDxidXR0b24KICAgICAgICAgICAgb25DbGljaz17b25DbG9zZX0KICAgICAgICAgICAgY2xhc3NOYW1lPSJncmlkIGgtOCB3LTggcGxhY2UtaXRlbXMtY2VudGVyIHJvdW5kZWQtZnVsbCBiZy13aGl0ZS8yMCBob3ZlcjpiZy13aGl0ZS8zMCIKICAgICAgICAgICAgYXJpYS1sYWJlbD0iQ2xvc2UiCiAgICAgICAgICA+CiAgICAgICAgICAgIOKclQogICAgICAgICAgPC9idXR0b24+CiAgICAgICAgPC9oZWFkZXI+CgogICAgICAgIHsvKiBNZXNzYWdlcyAqL30KICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iZmxleC0xIHNwYWNlLXktMyBvdmVyZmxvdy15LWF1dG8gYmctZ3JheS01MCBwLTQiPgogICAgICAgICAge21lc3NhZ2VzLmxlbmd0aCA9PT0gMCAmJiAoCiAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJ0ZXh0LWNlbnRlciB0ZXh0LXNtIHRleHQtZ3JheS01MDAgcHQtOCI+CiAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9Im1iLTIgdGV4dC00eGwiPvCfjLE8L2Rpdj4KICAgICAgICAgICAgICA8cCBjbGFzc05hbWU9Im1iLTMgZm9udC1zZW1pYm9sZCB0ZXh0LWdyYXktNzAwIj57dCgnYWlfd2VsY29tZV90aXRsZScpfTwvcD4KICAgICAgICAgICAgICA8cCBjbGFzc05hbWU9InRleHQteHMiPnt0KCdhaV93ZWxjb21lX2hpbnQnKX08L3A+CiAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9Im10LTQgc3BhY2UteS0yIj4KICAgICAgICAgICAgICAgIHsobGFuZyA9PT0gJ2JuJwogICAgICAgICAgICAgICAgICA/IFsn4KaG4Kac4KaV4KeH4KawIOCmrOCmvuCmnOCmvuCmsOCmpuCmsCDgppXgp4A/JywgJ+CmleCni+CmqCDgpqvgprjgprIg4Kay4Ka+4KaX4Ka+4Kao4KeLIOCmreCmvuCmsuCniz8nLCAn4Kaq4Ka+4Kak4Ka+4Kav4Ka8IOCmpuCmvuCmlyDgppXgp4fgpqgg4Ka54Kav4Ka8PyddCiAgICAgICAgICAgICAgICAgIDogWydXaGF0IGFyZSB0b2RheVwncyBwcmljZXM/JywgJ1doaWNoIGNyb3Agc2hvdWxkIEkgZ3Jvdz8nLCAnV2h5IGFyZSBsZWF2ZXMgc3BvdHRpbmc/J10KICAgICAgICAgICAgICAgICkubWFwKChleGFtcGxlKSA9PiAoCiAgICAgICAgICAgICAgICAgIDxidXR0b24KICAgICAgICAgICAgICAgICAgICBrZXk9e2V4YW1wbGV9CiAgICAgICAgICAgICAgICAgICAgb25DbGljaz17KCkgPT4gc2V0SW5wdXQoZXhhbXBsZSl9CiAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPSJibG9jayB3LWZ1bGwgcm91bmRlZC1mdWxsIGJvcmRlciBib3JkZXItZ3JheS0yMDAgYmctd2hpdGUgcHgtNCBweS0yIHRleHQteHMgdGV4dC1ncmF5LTYwMCBob3Zlcjpib3JkZXItbTEgaG92ZXI6dGV4dC1tMSIKICAgICAgICAgICAgICAgICAgPgogICAgICAgICAgICAgICAgICAgIHtleGFtcGxlfQogICAgICAgICAgICAgICAgICA8L2J1dHRvbj4KICAgICAgICAgICAgICAgICkpfQogICAgICAgICAgICAgIDwvZGl2PgogICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICl9CgogICAgICAgICAge21lc3NhZ2VzLm1hcCgobSwgaSkgPT4gKAogICAgICAgICAgICA8ZGl2IGtleT17aX0gY2xhc3NOYW1lPXtgZmxleCAke20ucm9sZSA9PT0gJ3VzZXInID8gJ2p1c3RpZnktZW5kJyA6ICdqdXN0aWZ5LXN0YXJ0J31gfT4KICAgICAgICAgICAgICA8ZGl2CiAgICAgICAgICAgICAgICBjbGFzc05hbWU9e2BtYXgtdy1bODUlXSByb3VuZGVkLTJ4bCBweC00IHB5LTIgdGV4dC1zbSAkewogICAgICAgICAgICAgICAgICBtLnJvbGUgPT09ICd1c2VyJwogICAgICAgICAgICAgICAgICAgID8gJ2JnLW0xIHRleHQtd2hpdGUnCiAgICAgICAgICAgICAgICAgICAgOiAnYmctd2hpdGUgdGV4dC1ncmF5LTgwMCBzaGFkb3ctc20gYm9yZGVyIGJvcmRlci1ncmF5LTEwMCcKICAgICAgICAgICAgICAgIH1gfQogICAgICAgICAgICAgID4KICAgICAgICAgICAgICAgIHttLmltYWdlICYmICgKICAgICAgICAgICAgICAgICAgPGltZwogICAgICAgICAgICAgICAgICAgIHNyYz17bS5pbWFnZX0KICAgICAgICAgICAgICAgICAgICBhbHQ9IiIKICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9Im1iLTIgbWF4LWgtNDggcm91bmRlZC1sZyBvYmplY3QtY292ZXIiCiAgICAgICAgICAgICAgICAgIC8+CiAgICAgICAgICAgICAgICApfQogICAgICAgICAgICAgICAge20udGV4dCAmJiA8ZGl2IGNsYXNzTmFtZT0id2hpdGVzcGFjZS1wcmUtd3JhcCI+e20udGV4dH08L2Rpdj59CiAgICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICAgIDwvZGl2PgogICAgICAgICAgKSl9CgogICAgICAgICAge2J1c3kgJiYgKAogICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0iZmxleCBqdXN0aWZ5LXN0YXJ0Ij4KICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT0icm91bmRlZC0yeGwgYmctd2hpdGUgcHgtNCBweS0yIHNoYWRvdy1zbSBib3JkZXIgYm9yZGVyLWdyYXktMTAwIj4KICAgICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJmbGV4IGdhcC0xIj4KICAgICAgICAgICAgICAgICAgPHNwYW4gY2xhc3NOYW1lPSJoLTIgdy0yIGFuaW1hdGUtYm91bmNlIHJvdW5kZWQtZnVsbCBiZy1tMSIgc3R5bGU9e3sgYW5pbWF0aW9uRGVsYXk6ICcwbXMnIH19IC8+CiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzTmFtZT0iaC0yIHctMiBhbmltYXRlLWJvdW5jZSByb3VuZGVkLWZ1bGwgYmctbTEiIHN0eWxlPXt7IGFuaW1hdGlvbkRlbGF5OiAnMTUwbXMnIH19IC8+CiAgICAgICAgICAgICAgICAgIDxzcGFuIGNsYXNzTmFtZT0iaC0yIHctMiBhbmltYXRlLWJvdW5jZSByb3VuZGVkLWZ1bGwgYmctbTEiIHN0eWxlPXt7IGFuaW1hdGlvbkRlbGF5OiAnMzAwbXMnIH19IC8+CiAgICAgICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgICA8L2Rpdj4KICAgICAgICAgICAgPC9kaXY+CiAgICAgICAgICApfQoKICAgICAgICAgIDxkaXYgcmVmPXtib3R0b21SZWZ9IC8+CiAgICAgICAgPC9kaXY+CgogICAgICAgIHsvKiBFcnJvciBiYW5uZXIgKi99CiAgICAgICAge2Vycm9yICYmICgKICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJib3JkZXItdCBib3JkZXItZGFuZ2VyLWRhcmsvMzAgYmctZGFuZ2VyLWJnIHB4LTQgcHktMiB0ZXh0LXhzIHRleHQtZGFuZ2VyLWRhcmsiPgogICAgICAgICAgICB7ZXJyb3J9CiAgICAgICAgICA8L2Rpdj4KICAgICAgICApfQoKICAgICAgICB7LyogSW1hZ2UgcHJldmlldyBhYm92ZSBpbnB1dCAqL30KICAgICAgICB7aW1hZ2VQcmV2aWV3ICYmICgKICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJib3JkZXItdCBib3JkZXItZ3JheS0yMDAgYmctd2hpdGUgcHgtNCBweS0yIGZsZXggaXRlbXMtY2VudGVyIGdhcC0zIj4KICAgICAgICAgICAgPGltZyBzcmM9e2ltYWdlUHJldmlld30gYWx0PSJwcmV2aWV3IiBjbGFzc05hbWU9ImgtMTYgdy0xNiByb3VuZGVkLWxnIG9iamVjdC1jb3ZlciIgLz4KICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9ImZsZXgtMSB0ZXh0LXhzIHRleHQtZ3JheS02MDAgdHJ1bmNhdGUiPntpbWFnZT8ubmFtZX08L2Rpdj4KICAgICAgICAgICAgPGJ1dHRvbgogICAgICAgICAgICAgIG9uQ2xpY2s9e3JlbW92ZUltYWdlfQogICAgICAgICAgICAgIGNsYXNzTmFtZT0idGV4dC1kYW5nZXItZGFyayBob3ZlcjpvcGFjaXR5LTgwIHRleHQtbGciCiAgICAgICAgICAgICAgYXJpYS1sYWJlbD0iUmVtb3ZlIgogICAgICAgICAgICA+CiAgICAgICAgICAgICAg4pyVCiAgICAgICAgICAgIDwvYnV0dG9uPgogICAgICAgICAgPC9kaXY+CiAgICAgICAgKX0KCiAgICAgICAgey8qIElucHV0ICovfQogICAgICAgIDxkaXYgY2xhc3NOYW1lPSJib3JkZXItdCBib3JkZXItZ3JheS0yMDAgYmctd2hpdGUgcC0zIj4KICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPSJmbGV4IGl0ZW1zLWVuZCBnYXAtMiI+CiAgICAgICAgICAgIDxidXR0b24KICAgICAgICAgICAgICB0eXBlPSJidXR0b24iCiAgICAgICAgICAgICAgb25DbGljaz17KCkgPT4gZmlsZUlucHV0UmVmLmN1cnJlbnQ/LmNsaWNrKCl9CiAgICAgICAgICAgICAgZGlzYWJsZWQ9e2J1c3l9CiAgICAgICAgICAgICAgY2xhc3NOYW1lPSJncmlkIGgtMTAgdy0xMCBwbGFjZS1pdGVtcy1jZW50ZXIgcm91bmRlZC1mdWxsIGJnLWdyYXktMTAwIHRleHQtZ3JheS02MDAgaG92ZXI6YmctZ3JheS0yMDAgZGlzYWJsZWQ6b3BhY2l0eS01MCIKICAgICAgICAgICAgICBhcmlhLWxhYmVsPSJBdHRhY2ggaW1hZ2UiCiAgICAgICAgICAgICAgdGl0bGU9e3QoJ2FpX2F0dGFjaCcpfQogICAgICAgICAgICA+CiAgICAgICAgICAgICAg8J+TjgogICAgICAgICAgICA8L2J1dHRvbj4KICAgICAgICAgICAgPGlucHV0CiAgICAgICAgICAgICAgcmVmPXtmaWxlSW5wdXRSZWZ9CiAgICAgICAgICAgICAgdHlwZT0iZmlsZSIKICAgICAgICAgICAgICBhY2NlcHQ9ImltYWdlL2pwZWcsaW1hZ2UvcG5nLGltYWdlL3dlYnAiCiAgICAgICAgICAgICAgb25DaGFuZ2U9e3BpY2tJbWFnZX0KICAgICAgICAgICAgICBjbGFzc05hbWU9ImhpZGRlbiIKICAgICAgICAgICAgLz4KICAgICAgICAgICAgPHRleHRhcmVhCiAgICAgICAgICAgICAgdmFsdWU9e2lucHV0fQogICAgICAgICAgICAgIG9uQ2hhbmdlPXsoZSkgPT4gc2V0SW5wdXQoZS50YXJnZXQudmFsdWUpfQogICAgICAgICAgICAgIG9uS2V5RG93bj17b25LZXl9CiAgICAgICAgICAgICAgcGxhY2Vob2xkZXI9e3QoJ2FpX2lucHV0X3BsYWNlaG9sZGVyJyl9CiAgICAgICAgICAgICAgcm93cz17MX0KICAgICAgICAgICAgICBkaXNhYmxlZD17YnVzeX0KICAgICAgICAgICAgICBjbGFzc05hbWU9ImZsZXgtMSByZXNpemUtbm9uZSByb3VuZGVkLTJ4bCBib3JkZXIgYm9yZGVyLWdyYXktMjAwIHB4LTQgcHktMiB0ZXh0LXNtIG91dGxpbmUtbm9uZSBmb2N1czpib3JkZXItbTEgZGlzYWJsZWQ6YmctZ3JheS01MCIKICAgICAgICAgICAgICBzdHlsZT17eyBtYXhIZWlnaHQ6ICcxMjBweCcgfX0KICAgICAgICAgICAgLz4KICAgICAgICAgICAgPGJ1dHRvbgogICAgICAgICAgICAgIHR5cGU9ImJ1dHRvbiIKICAgICAgICAgICAgICBvbkNsaWNrPXtzZW5kfQogICAgICAgICAgICAgIGRpc2FibGVkPXtidXN5IHx8ICghaW5wdXQudHJpbSgpICYmICFpbWFnZSl9CiAgICAgICAgICAgICAgY2xhc3NOYW1lPSJncmlkIGgtMTAgdy0xMCBwbGFjZS1pdGVtcy1jZW50ZXIgcm91bmRlZC1mdWxsIGJnLW0xIHRleHQtd2hpdGUgaG92ZXI6YmctbTEtZGFyayBkaXNhYmxlZDpvcGFjaXR5LTUwIgogICAgICAgICAgICAgIGFyaWEtbGFiZWw9IlNlbmQiCiAgICAgICAgICAgID4KICAgICAgICAgICAgICDinqQKICAgICAgICAgICAgPC9idXR0b24+CiAgICAgICAgICA8L2Rpdj4KICAgICAgICAgIDxwIGNsYXNzTmFtZT0ibXQtMSB0ZXh0LWNlbnRlciB0ZXh0LVsxMHB4XSB0ZXh0LWdyYXktNDAwIj57dCgnYWlfZGlzY2xhaW1lcicpfTwvcD4KICAgICAgICA8L2Rpdj4KICAgICAgPC9hc2lkZT4KICAgIDwvPgogICk7Cn0K' | base64 -d > 'frontend/src/components/ui/AiChatDrawer.jsx' && say 'wrote frontend/src/components/ui/AiChatDrawer.jsx'

echo "==> [2/5] Installing @google/generative-ai..."
( cd backend && npm install @google/generative-ai >/tmp/gg.log 2>&1 && say "installed" || { say "FAILED — see /tmp/gg.log"; cat /tmp/gg.log | tail -5; exit 1; } )

echo "==> [3/5] Wiring backend/src/index.js (mount /api/ai)..."
"$PY" - backend/src/index.js << 'PY'
import sys
f = sys.argv[1]
with open(f, encoding='utf-8') as fh: s = fh.read()
if 'ai.routes.js' in s:
    print("  already wired"); sys.exit(0)
# add import after authRoutes import
if "import authRoutes from './routes/auth.routes.js';" in s:
    s = s.replace(
        "import authRoutes from './routes/auth.routes.js';",
        "import authRoutes from './routes/auth.routes.js';\nimport aiRoutes from './routes/ai.routes.js';",
        1
    )
else:
    print("  ERROR: authRoutes import not found"); sys.exit(1)
# mount after /api/auth
import re
m = re.search(r"app\.use\('/api/auth', authRoutes\);", s)
if m:
    ins = "\napp.use('/api/ai', aiRoutes);"
    s = s[:m.end()] + ins + s[m.end():]
    with open(f, 'w', encoding='utf-8') as fh: fh.write(s)
    print("  wired /api/ai")
else:
    print("  ERROR: /api/auth mount not found"); sys.exit(1)
PY

echo "==> [4/5] Adding AI Help button + drawer to FarmerDashboard..."
"$PY" - frontend/src/pages/farmer/FarmerDashboard.jsx << 'PY'
import sys, re
f = sys.argv[1]
with open(f, encoding='utf-8') as fh: s = fh.read()

if 'AiChatDrawer' in s:
    print("  already added"); sys.exit(0)

# 1) add import + useState for chat open state
# find import block end (last import line)
imports = list(re.finditer(r'^import .+;', s, re.MULTILINE))
if not imports:
    print("  ERROR: no imports found"); sys.exit(1)
last_import_end = imports[-1].end()
new_import = "\nimport AiChatDrawer from '../../components/ui/AiChatDrawer.jsx';"
s = s[:last_import_end] + new_import + s[last_import_end:]

# 2) add useState for chatOpen inside the component (after the first useState)
# find first "const [X, setX] = useState(" inside function
m = re.search(r'(export default function \w+\([^)]*\)\s*\{)', s)
if not m:
    print("  ERROR: component function not found"); sys.exit(1)
comp_body_start = m.end()
# inject after component brace
chat_state = "\n  const [chatOpen, setChatOpen] = useState(false);\n"
s = s[:comp_body_start] + chat_state + s[comp_body_start:]

# 3) inject the floating button + drawer BEFORE the final closing </...> of the return
# Find the last "</>" or "</div>" of the component return
# safest: find the last "  );" before the closing "}" of the function
# We insert before it.
# Look for a "\n    </>\n  );" or similar
patterns = [
    r'(\n\s*</>\s*\n\s*\);)',   # React fragment close
    r'(\n\s*</div>\s*\n\s*\);)', # div close
]

inject = """
      {/* Floating AI Help button */}
      <button
        onClick={() => setChatOpen(true)}
        className="fixed bottom-6 right-6 z-[800] flex items-center gap-2 rounded-full bg-m1 px-5 py-3 font-semibold text-white shadow-3 hover:bg-m1-dark transition"
        aria-label="AI Help"
      >
        <span className="text-lg">🤖</span>
        <span>{t('ai_help_button')}</span>
      </button>
      <AiChatDrawer open={chatOpen} onClose={() => setChatOpen(false)} />
"""

replaced = False
for pat in patterns:
    m = re.search(pat, s)
    if m:
        s = s[:m.start()] + inject + s[m.start():]
        replaced = True
        break
if not replaced:
    print("  WARN: could not find return-close pattern; button not injected"); sys.exit(1)

with open(f, 'w', encoding='utf-8') as fh: fh.write(s)
print("  injected AI Help button + drawer")
PY

echo "==> [5/5] Adding i18n keys..."
if grep -q "ai_title" frontend/src/i18n/strings.js; then
  say "already present"
else
"$PY" - frontend/src/i18n/strings.js << 'PY'
import re, sys
f = sys.argv[1]
with open(f, encoding='utf-8') as fh: s = fh.read()

BN = {
    'ai_help_button': 'AI সহায়ক',
    'ai_title': 'AgroMart AI',
    'ai_subtitle': 'আপনার কৃষি সহকারী',
    'ai_welcome_title': 'কেমন সাহায্য করতে পারি?',
    'ai_welcome_hint': 'যেকোনো ফসল, রোগ, বা বাজারদর সম্পর্কে জিজ্ঞাসা করুন। ছবিও পাঠাতে পারেন।',
    'ai_input_placeholder': 'একটি প্রশ্ন লিখুন...',
    'ai_attach': 'ছবি যোগ করুন',
    'ai_image_too_big': 'ছবি ৪MB এর কম হতে হবে',
    'ai_disclaimer': 'AI-এর উত্তর সবসময় সঠিক নাও হতে পারে',
}
EN = {
    'ai_help_button': 'AI Help',
    'ai_title': 'AgroMart AI',
    'ai_subtitle': 'Your farming assistant',
    'ai_welcome_title': 'How can I help you?',
    'ai_welcome_hint': 'Ask about any crop, disease, or market price. You can also send a photo.',
    'ai_input_placeholder': 'Ask a question...',
    'ai_attach': 'Attach image',
    'ai_image_too_big': 'Image must be under 4MB',
    'ai_disclaimer': 'AI responses may not always be accurate',
}

def js_val(v):
    if "'" not in v: return "'" + v + "'"
    if '"' not in v: return '"' + v + '"'
    return "'" + v.replace("'", "\\'") + "'"

def insert(text, block, entries):
    m = re.search(r'(\b' + block + r'\s*:\s*\{)', text)
    if not m: return text, 0
    start = m.end(); depth = 1; i = start
    while i < len(text) and depth > 0:
        if text[i] == '{': depth += 1
        elif text[i] == '}': depth -= 1
        i += 1
    close = i - 1; body = text[start:close]
    lines = [f"    {k}: {js_val(v)}," for k, v in entries.items() if f"{k}:" not in body]
    if not lines: return text, 0
    return text[:close] + "\n" + "\n".join(lines) + "\n" + text[close:], len(lines)

s, a = insert(s, 'bn', BN)
s, b = insert(s, 'en', EN)
with open(f, 'w', encoding='utf-8') as fh: fh.write(s)
print(f"  added {a} bn + {b} en keys")
PY
fi

echo ""
echo "════ AI Assistant applied. ════"
echo ""
echo "⚠️  IMPORTANT: Add your Gemini API key to backend/.env before restarting:"
echo "    echo 'GEMINI_API_KEY=your_key_here' >> backend/.env"
echo ""
echo "Then restart backend (Ctrl+C then npm run dev)."
echo ""
echo "Test:"
echo "  1. Log in as farmer (01700000002 / demo1234)"
echo "  2. On farmer dashboard, click '🤖 AI Help' bottom-right"
echo "  3. Ask a question (with or without photo)"
