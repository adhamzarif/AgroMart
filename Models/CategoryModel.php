<?php
/**
 * CategoryModel — crop categories admin CRUD.
 */
class CategoryModel extends Model {

    public function all() {
        // crops_count changes often; cache only 5 min
        return Cache::remember('categories:all', 300, function() {
            return $this->fetchAll(
                "SELECT cc.*,
                        pc.category_name_bn AS parent_name,
                        (SELECT COUNT(*) FROM crops WHERE category_id = cc.category_id) AS crops_count
                 FROM crop_categories cc
                 LEFT JOIN crop_categories pc ON cc.parent_category_id = pc.category_id
                 ORDER BY cc.category_id"
            );
        });
    }

    /** Fetch a single category — cached for 1 hour. */
    public function find($categoryId) {
        return Cache::remember('categories:id:' . (int)$categoryId, 3600, function() use ($categoryId) {
            return $this->fetchOne("SELECT * FROM crop_categories WHERE category_id = ?", [$categoryId]);
        });
    }

    /** Invalidate every category-related cache key after a write. */
    private function bust() {
        Cache::forget('categories:all');
        Cache::forgetPrefix('categories:id:');
    }

    public function create(array $data) {
        // Uniqueness check
        if ($this->fetchScalar("SELECT 1 FROM crop_categories WHERE category_name = ? OR category_name_bn = ?",
            [$data['category_name'], $data['category_name_bn']])) {
            return ['ok' => false, 'error' => 'এই ক্যাটাগরি ইতোমধ্যে বিদ্যমান।'];
        }
        $this->execute(
            "INSERT INTO crop_categories (category_name, category_name_bn, parent_category_id, description, icon)
             VALUES (?,?,?,?,?)",
            [
                $data['category_name'], $data['category_name_bn'],
                !empty($data['parent_category_id']) ? (int)$data['parent_category_id'] : null,
                $data['description'] ?? null,
                $data['icon'] ?? null,
            ]
        );
        $this->bust();
        return ['ok' => true, 'category_id' => $this->lastInsertId()];
    }

    public function update($categoryId, array $data) {
        $this->execute(
            "UPDATE crop_categories
             SET category_name = ?, category_name_bn = ?, parent_category_id = ?, description = ?, icon = ?
             WHERE category_id = ?",
            [
                $data['category_name'], $data['category_name_bn'],
                !empty($data['parent_category_id']) ? (int)$data['parent_category_id'] : null,
                $data['description'] ?? null,
                $data['icon'] ?? null,
                $categoryId,
            ]
        );
        $this->bust();
        return ['ok' => true];
    }

    public function delete($categoryId) {
        // Prevent deletion if crops use it
        $count = (int)$this->fetchScalar("SELECT COUNT(*) FROM crops WHERE category_id = ?", [$categoryId]);
        if ($count > 0) {
            return ['ok' => false, 'error' => 'এই ক্যাটাগরিতে ' . bn_num($count) . ' টি ফসল আছে। আগে ফসলগুলি অন্য ক্যাটাগরিতে সরান।'];
        }
        $this->execute("DELETE FROM crop_categories WHERE category_id = ?", [$categoryId]);
        $this->bust();
        return ['ok' => true];
    }
}
