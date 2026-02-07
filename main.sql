
DROP TABLE IF EXISTS MusicVideo;

CREATE TABLE MusicVideo (
    track_id        INTEGER PRIMARY KEY,
    video_director  TEXT NOT NULL,
    FOREIGN KEY (track_id) REFERENCES tracks(TrackId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Hannah Park' FROM tracks
WHERE Name = 'For Those About To Rock (We Salute You)';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Diego Alvarez' FROM tracks
WHERE Name = 'Balls to the Wall';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Amina Khan' FROM tracks
WHERE Name = 'Fast As a Shark';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Noah Bennett' FROM tracks
WHERE Name = 'Restless and Wild';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Sofia Ionescu' FROM tracks
WHERE Name = 'Princess of the Dawn';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Kei Tanaka' FROM tracks
WHERE Name = 'Put The Finger On You';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Maya Desai' FROM tracks
WHERE Name = 'Let''s Get It Up';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Owen Clarke' FROM tracks
WHERE Name = 'Inject The Venom';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Lucia Moretti' FROM tracks
WHERE Name = 'Snowballed';

INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Ethan Walsh' FROM tracks
WHERE Name = 'Evil Walks';



INSERT INTO MusicVideo (track_id, video_director)
SELECT TrackId, 'Jordan Rivers'
FROM tracks
WHERE Name = 'Voodoo';



SELECT TrackId, Name
FROM tracks
WHERE Name LIKE '%á%' OR Name LIKE '%é%' OR Name LIKE '%í%' OR Name LIKE '%ó%' OR Name LIKE '%ú%'
   OR Name LIKE '%Á%' OR Name LIKE '%É%' OR Name LIKE '%Í%' OR Name LIKE '%Ó%' OR Name LIKE '%Ú%'
ORDER BY Name;



SELECT
    c.FirstName || ' ' || c.LastName AS Customer,
    t.Name AS Track,
    al.Title AS Album,
    ar.Name AS Artist,
    ii.UnitPrice,
    ii.Quantity,
    inv.InvoiceDate
FROM customers c
JOIN invoices inv        ON inv.CustomerId = c.CustomerId
JOIN invoice_items ii    ON ii.InvoiceId = inv.InvoiceId
JOIN tracks t            ON t.TrackId = ii.TrackId
LEFT JOIN albums al      ON al.AlbumId = t.AlbumId
LEFT JOIN artists ar     ON ar.ArtistId = al.ArtistId
ORDER BY inv.InvoiceDate DESC, Customer, Artist, Album, Track
LIMIT 50;



SELECT
    g.Name AS Genre,
    ROUND(SUM(ii.UnitPrice * ii.Quantity), 2) AS Revenue,
    COUNT(*) AS LineItems,
    SUM(ii.Quantity) AS TracksSold
FROM invoice_items ii
JOIN tracks t   ON t.TrackId = ii.TrackId
LEFT JOIN genres g ON g.GenreId = t.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY Revenue DESC;



WITH eligible_tracks AS (
    SELECT TrackId, Milliseconds
    FROM tracks
    WHERE Milliseconds <= 15 * 60 * 1000
),
avg_len AS (
    SELECT AVG(Milliseconds) AS avg_ms
    FROM eligible_tracks
),
longer_than_avg AS (
    SELECT et.TrackId
    FROM eligible_tracks et
    CROSS JOIN avg_len a
    WHERE et.Milliseconds > a.avg_ms
)
SELECT DISTINCT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS Customer,
    c.Email
FROM customers c
JOIN invoices inv      ON inv.CustomerId = c.CustomerId
JOIN invoice_items ii  ON ii.InvoiceId = inv.InvoiceId
JOIN longer_than_avg l ON l.TrackId = ii.TrackId
ORDER BY Customer;



WITH genre_totals AS (
    SELECT
        g.GenreId,
        g.Name AS Genre,
        SUM(t.Milliseconds) AS total_ms
    FROM genres g
    JOIN tracks t ON t.GenreId = g.GenreId
    GROUP BY g.GenreId, g.Name
),
top5 AS (
    SELECT GenreId
    FROM genre_totals
    ORDER BY total_ms DESC
    LIMIT 5
)
SELECT
    t.TrackId,
    t.Name,
    g.Name AS Genre,
    t.Milliseconds
FROM tracks t
LEFT JOIN genres g ON g.GenreId = t.GenreId
WHERE t.GenreId IS NULL
   OR t.GenreId NOT IN (SELECT GenreId FROM top5)
ORDER BY Genre, t.Name;
