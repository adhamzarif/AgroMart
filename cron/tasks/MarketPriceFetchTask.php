<?php
/**
 * MarketPriceFetchTask — daily pull of market prices from the configured feed
 * (or seed fallback) into market_prices via PriceModel::upsert().
 *
 * price_history is auto-maintained by the model whenever an existing
 * (crop, district, date) row is updated.
 *
 * Schedule: daily — prices update once per day in most BD wholesale markets.
 */
class MarketPriceFetchTask extends CronTask {

    public $name = 'market_price_fetch';
    public $schedule = 'daily';

    public function run() {
        require_once dirname(__DIR__, 2) . '/core/MarketPriceProvider.php';

        $result = MarketPriceProvider::fetch();
        if (!$result['ok'] && empty($result['rows'])) {
            return ['ok' => false, 'message' => $result['error'] ?? 'No data', 'affected' => 0];
        }

        $rows = $result['rows'];
        $upserted = 0;
        $skipped = 0;

        $priceModel = new PriceModel();
        $districtModel = new DistrictModel();

        foreach ($rows as $row) {
            try {
                $district = $districtModel->findByName($row['district_name']);
                if (!$district) {
                    $skipped++;
                    continue;
                }
                $priceModel->upsert([
                    'crop_name'       => $row['crop_name'],
                    'district_id'     => (int)$district['district_id'],
                    'wholesale_price' => (float)$row['wholesale_price'],
                    'retail_price'    => (float)$row['retail_price'],
                    'unit'            => $row['unit'] ?? 'kg',
                    'price_date'      => $row['price_date'],
                    'source'          => $row['source'] ?? 'auto',
                    'updated_by'      => null,
                ]);
                $upserted++;
            } catch (Throwable $e) {
                $this->log("Row {$row['crop_name']}/{$row['district_name']}: " . $e->getMessage());
                $skipped++;
            }
        }

        return [
            'ok' => true,
            'message' => sprintf('Source: %s — upserted %d prices, skipped %d', $result['source'], $upserted, $skipped),
            'affected' => $upserted,
        ];
    }
}
