<?php
/**
 * MarketplaceController
 * ─────────────────────────────────────────────────────────────
 * Public marketplace — shows ALL active crops from registered farmers.
 *
 * Routes:
 *   /marketplace        → landing preview (6 latest crops)
 *   /marketplace/all    → full paginated browse with filters
 *
 * Data source: CropModel::search() / CropModel::searchCount(), which
 * already filter to:
 *   - status = 'available' AND quantity > 0
 *   - owning user has 'farmer' role in user_roles
 *   - owning user has account_status = 'active'
 *
 * So when a farmer adds, edits, or removes a crop — or when an admin
 * suspends a farmer — the marketplace reflects it instantly with NO
 * additional code. Listings auto-disappear when stock hits zero.
 *
 * The previous version used CropModel::getConnectedFarmerCrops() which
 * only showed crops from farmers the buyer had already ordered from. That
 * made the marketplace appear empty/broken for new users — which is the
 * opposite of what a discovery surface should do.
 */
class MarketplaceController extends Controller {

    /** Public marketplace landing — 6 latest active crops. */
    public function index() {
        $currentUserId = $_SESSION['user_id'] ?? null;
        $cropModel = new \CropModel();

        // Show ALL active farmer crops, newest first.
        // The search() method handles the "only-real-farmers" filter for us.
        $crops = $cropModel->search([], 6, 0);

        $title = 'মার্কেটপ্লেস | AgroFin';
        $this->view('marketplace/index', compact('title', 'crops', 'currentUserId'));
    }

    /** Full paginated marketplace browse with optional filters. */
    public function all() {
        $currentUserId = $_SESSION['user_id'] ?? null;
        $cropModel = new \CropModel();

        // Read filter inputs from query string (all optional)
        $filters = array_filter([
            'q'           => $_GET['q']           ?? null,
            'category_id' => $_GET['category_id'] ?? null,
            'district_id' => $_GET['district_id'] ?? null,
            'min_price'   => $_GET['min_price']   ?? null,
            'max_price'   => $_GET['max_price']   ?? null,
            'quality'     => $_GET['quality']     ?? null,
            'organic'     => $_GET['organic']     ?? null,
            'sort'        => $_GET['sort']        ?? null,
        ], fn($v) => $v !== null && $v !== '');

        $page   = max(1, (int)($_GET['page'] ?? 1));
        $limit  = 24;
        $offset = ($page - 1) * $limit;

        $crops      = $cropModel->search($filters, $limit, $offset);
        $totalCrops = $cropModel->searchCount($filters);
        $totalPages = max(1, (int)ceil($totalCrops / $limit));

        $title = 'সব ফসল | AgroFin Marketplace';
        $this->view(
            'marketplace/all',
            compact('title', 'crops', 'currentUserId', 'totalPages', 'page', 'totalCrops')
        );
    }
}
