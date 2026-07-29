<?php
class DistrictModel extends Model {
    public function all() {
        // Districts rarely change — cache for 1 day
        return Cache::remember('districts:all', 86400, function() {
            return $this->fetchAll("SELECT * FROM districts ORDER BY district_name ASC");
        });
    }
    public function find($id) {
        return Cache::remember('districts:id:' . (int)$id, 86400, function() use ($id) {
            return $this->fetchOne("SELECT * FROM districts WHERE district_id = ?", [$id]);
        });
    }
    public function findByName($name) {
        return $this->fetchOne("SELECT * FROM districts WHERE district_name = ? LIMIT 1", [$name]);
    }
}
