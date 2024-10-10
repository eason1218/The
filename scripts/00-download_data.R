#### Preamble ####
# Purpose: Download data
# Author: team 52
# Date: 2024/10/10
# License: MIT

#### Workspace setup ###
#install.packages("devtools")
#devtools::install_github('charlie86/spotifyr')

library(spotifyr)
library(dplyr)
library(ggplot2)
library(purrr)
library(usethis)

edit_r_environ()

access_token <- get_spotify_access_token()
artist_name <- "The Beatles"
artist <- search_spotify(artist_name, type = "artist")
artist_id <- artist$id[1]
albums <- get_artist_albums(artist_id, include_groups = "album", market = "US")
album_ids <- albums$id
all_tracks <- list()
for (album_id in album_ids) {
  tracks <- get_album_tracks(album_id)
  all_tracks <- bind_rows(all_tracks, tracks)
}
track_ids <- all_tracks$id
batch_size <- 100
track_batches <- split(track_ids, ceiling(seq_along(track_ids) / batch_size))
audio_features_full <- data.frame()
for (batch in track_batches) {
  batch_audio_features <- get_track_audio_features(batch)
  audio_features_full <- bind_rows(audio_features_full, batch_audio_features)
}
full_data <- audio_features_full %>%
  left_join(all_tracks, by = c("id" = "id"))
saveRDS(full_data, file = "the_beatles_audio_features.rds")

