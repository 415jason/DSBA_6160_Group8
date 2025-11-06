CREATE TABLE spotify_tracks (
    tracks_id VARCHAR(50),
    tracks_name VARCHAR(255),
    tracks_popularity INT,
    tracks_duration_ms INT,
    tracks_explicit BOOLEAN,
    artists_name TEXT,
    artists_id TEXT,
    tracks_release_date DATE,
    tracks_danceability FLOAT,
    tracks_energy FLOAT,
    tracks_key INT,
    tracks_loudness FLOAT,
    tracks_mode INT,
    tracks_speechiness FLOAT,
    tracks_acousticness FLOAT,
    tracks_instrumentalness FLOAT,
    tracks_liveness FLOAT,
    tracks_valence FLOAT,
    tracks_tempo FLOAT,
    tracks_time_signature INT
);

CREATE TABLE spotify_artists (
    artists_id VARCHAR(50),
    artists_name VARCHAR(255),
    artists_followers INT,
    artists_genres TEXT,
    artists_popularity INT
);