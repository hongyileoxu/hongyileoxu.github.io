# Hongyi Xu - academic website

A Jekyll website for an academic finance profile, designed for GitHub Pages.

## Main content

- `index.html`: homepage biography, research interests, and contact
- `research/index.md`: working papers and publication record
- `cv/index.html`: CV page with embedded viewer and download link
- `blog/index.html`: research notes
- `projects/index.md`: replication and project archive
- `_layouts/default.html`: shared navigation and footer
- `css/main.css`: typography, colors, layout, and responsive styles

The header uses the official black SSE logo stored at `asset/sse-logo.svg`.

## Updating job-market materials

The homepage portrait is stored at `asset/profile.jpg`. The current CV is stored at `cv.pdf` and displayed through `cv/index.html`.

To replace the portrait later, overwrite `asset/profile.jpg`. The tall crop is controlled by `.profile-photo` in `css/main.css`.

To update the CV, overwrite `cv.pdf` with the new version. The existing viewer and download link will continue to work. Paper links can be added to the corresponding entries in `research/index.md`.

GitHub Pages rebuilds the site when changes are pushed to the publishing branch.
