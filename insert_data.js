const { createClient } = require('@clickhouse/client');
const { writeFileSync, createReadStream } = require('fs');
const { parser } = require('stream-json');
const StreamArray = require('stream-json/streamers/StreamArray.js');
const { chain } = require('stream-chain');
const { v4 } = require('uuid');

const client = createClient({
  format: 'json',
  raw: false,
});

const createTableQuery = `
  CREATE TABLE IF NOT EXISTS clickhouse_exp (
    id UInt64,
    shortUrl String,
    longUrl String,
    source String,
    totalClicks UInt64 DEFAULT 0,
    iosClicks UInt64 DEFAULT 0,
    androidClicks UInt64 DEFAULT 0,
    webClicks UInt64 DEFAULT 0,
    firstOpenedAt DateTime DEFAULT NULL,
    lastOpenedAt DateTime DEFAULT NULL,
    tag String,
    feature String,
    campaign String,
    createdAt DateTime DEFAULT now(),
    updatedAt DateTime DEFAULT now(),
    INDEX shortUrl_index (shortUrl) TYPE minmax GRANULARITY 3,
    INDEX tag_index (tag) TYPE minmax GRANULARITY 3,
    INDEX feature_index (feature) TYPE minmax GRANULARITY 3,
    INDEX campaign_index (campaign) TYPE minmax GRANULARITY 3
  ) ENGINE = MergeTree()
  ORDER BY id;
`;

function convertToClickHouseDateTime(dateString) {
  if(!dateString) return null;

  const date = new Date(dateString);

  const pad = (num) => num.toString().padStart(2, '0');

  const year = date.getUTCFullYear();
  const month = pad(date.getUTCMonth() + 1); // Months are zero-based
  const day = pad(date.getUTCDate());
  const hours = pad(date.getUTCHours());
  const minutes = pad(date.getUTCMinutes());
  const seconds = pad(date.getUTCSeconds());

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

async function insertData() {
  const docs = chain([
      createReadStream('routerx.url-shortener.json'),
      parser(),
      new StreamArray(),
    ]);
    const startTime = new Date();
    let counter = 1;
    let batch = [];
    const analytics = {
      batchInfo: [],
      totalLinks: 0,
      totalInsertionTime: 0,
      batchSize: 10000,
    }

    for await (const { value:doc } of docs) {
      if(counter % 10000 == 0) {
        const batchStartTime = new Date();
        await client.insert({table: 'clickhouse_exp', values: batch, format: 'JSON'});
        const batchEndTime = new Date();
        const totalTime = batchEndTime.getTime() - batchStartTime.getTime();
        console.log(`TOTAL TIME FOR BATCH: ${totalTime}ms`)

        analytics.batchInfo.push({batchStartTime, batchEndTime, totalTime});
        batch = [];
        counter++;
      }else {
        batch.push({
          id: doc.id,
          shortUrl: doc.shortUrl,
          longUrl: doc.longUrl,
          source: doc.source,
          totalClicks: doc.analytics.clicks,
          iosClicks: doc.analytics.redirectionAnalytics.iosCount,
          androidClicks: doc.analytics.redirectionAnalytics.androidCount,
          webClicks: doc.analytics.redirectionAnalytics.webCount,
          firstOpenedAt: convertToClickHouseDateTime(doc.analytics.firstOpenedAt?.['$date']),
          lastOpenedAt: convertToClickHouseDateTime(doc.analytics.lastOpenedAt?.['$date']),
          tag: doc.analytics.tag,
          feature: doc.analytics.feature,
          campaign: doc.analytics.campaign,
          createdAt: convertToClickHouseDateTime(doc.createdAt['$date']),
          updatedAt: convertToClickHouseDateTime(doc.updatedAt['$date']),
        });
        counter++;
      }
    }

    console.log(`Insertion of ${counter} documents took ${new Date().getTime() - startTime.getTime()}ms`);

    writeFileSync(`log_${v4()}.json`, JSON.stringify(analytics));
}

async function createTable() {
  try {
    await client.ping();
    await client.query({query: createTableQuery});
    console.log('Table created successfully');
    await insertData();
  } catch (error) {
    console.error('Error creating table:', error);
  }

  return;
}

createTable();

module.exports = {client};