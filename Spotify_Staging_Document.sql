CREATE DATABASE spotify_db;
USE spotify_db;

CREATE TABLE stg_spotify_tracks (
    id VARCHAR(50),
    name TEXT,
    popularity INT,
    duration_ms INT,
    explicit BOOLEAN,
    artists TEXT,
    id_artists JSON,
    release_date VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    `key` INT,
    loudness FLOAT,
    mode INT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    time_signature INT
);

CREATE TABLE stg_spotify_artists (
    id VARCHAR(50),
    name TEXT,
    followers INT,
    genres JSON,
    popularity INT
);

CREATE TABLE dim_artists (
    artist_id VARCHAR(50) PRIMARY KEY,
    artist_name TEXT,
    artist_followers INT,
    artist_popularity INT
);

CREATE TABLE dim_tracks (
    track_id VARCHAR(50) PRIMARY KEY,
    track_name TEXT,
    track_popularity INT,
    track_duration_ms INT,
    track_explicit BOOLEAN,
    track_release_date VARCHAR(50),
    track_danceability FLOAT,
    track_energy FLOAT,
    track_key INT,
    track_loudness FLOAT,
    track_mode INT,
    track_speechiness FLOAT,
    track_acousticness FLOAT,
    track_instrumentalness FLOAT,
    track_liveness FLOAT,
    track_valence FLOAT,
    track_tempo FLOAT,
    track_time_signature INT
);

CREATE TABLE bridge_track_artists (
    track_id VARCHAR(50),
    artist_id VARCHAR(50),
    PRIMARY KEY (track_id, artist_id),
    FOREIGN KEY (track_id) REFERENCES dim_tracks(track_id),
    FOREIGN KEY (artist_id) REFERENCES dim_artists(artist_id)
);

# Populate dimension tables
INSERT INTO dim_artists (artist_id, artist_name, artist_followers, artist_popularity)
SELECT DISTINCT
    id AS artist_id,
    name AS artist_name,
    followers AS artist_followers,
    popularity AS artist_popularity
FROM stg_spotify_artists;

INSERT INTO dim_tracks (
    track_id, track_name, track_popularity, track_duration_ms, track_explicit,
    track_release_date, track_danceability, track_energy, track_key,
    track_loudness, track_mode, track_speechiness, track_acousticness,
    track_instrumentalness, track_liveness, track_valence, track_tempo,
    track_time_signature
)
SELECT DISTINCT
    id AS track_id,
    name AS track_name,
    popularity AS track_popularity,
    duration_ms AS track_duration_ms,
    explicit AS track_explicit,
    release_date AS track_release_date,
    danceability AS track_danceability,
    energy AS track_energy,
    `key` AS track_key,
    loudness AS track_loudness,
    mode AS track_mode,
    speechiness AS track_speechiness,
    acousticness AS track_acousticness,
    instrumentalness AS track_instrumentalness,
    liveness AS track_liveness,
    valence AS track_valence,
    tempo AS track_tempo,
    time_signature AS track_time_signature
FROM stg_spotify_tracks;

# Populate bridge table (after dims are filled)
INSERT INTO bridge_track_artists (track_id, artist_id)
SELECT 
    t.id AS track_id,
    jt.artist_id
FROM stg_spotify_tracks AS t,
JSON_TABLE(t.id_artists, '$[*]' COLUMNS (artist_id VARCHAR(50) PATH '$')) AS jt
WHERE jt.artist_id IS NOT NULL
  AND jt.artist_id IN (SELECT artist_id FROM dim_artists)
  AND t.id IN (SELECT track_id FROM dim_tracks);
