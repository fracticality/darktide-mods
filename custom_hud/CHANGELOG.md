# Changelog
## v2.1.4

### Added

- **User-managed ignore list** - The customization panel can now ignore noisy or unwanted HUD elements without deleting their saved layout. Double-click a panel row to ignore an element, open the **Ignore** side panel to review ignored elements, and double-click an ignored entry to restore it.
- **Fixed Arrow Movement** - Added an optional fixed-step arrow-key movement mode for edit mode. When enabled, each arrow-key tap moves the selected element by a configurable pixel step instead of continuously nudging by 1px while the key is held.
- **Additional protected elements** - Added built-in exclusions for `HudElementCrosshairHud`, `HudElementRingHud_player`, and `HudElementRingHud_team_docked` so crosshair and external overlay elements are not exposed for editing.

### Changed

- **DMF enable/disable handling** - Custom HUD now checks the mod enabled state during HUD init, toggle commands, draw/update hooks, saved-layout application, and visibility validation.
- **HUD recreation cleanup** - HUD rebuilds now remove stale Custom HUD element and visibility-group entries, skip unloadable element definitions, and safely no-op when UI or player state is unavailable.
- **Options-view behavior** - Closing the options views now refreshes cached settings and exits customization mode without forcing a full HUD rebuild.
- **Draw hook cleanup** - Draw hooks now use explicit draw arguments and the cached opacity accessor instead of vararg/select handling.

### Fixed

- **Disable cleanup** - Disabling the mod now clears edit/hidden state, removes runtime position overrides, unhides affected elements, and recreates the HUD cleanly.
- **Position overrides after update** - Saved scenegraph positions are re-applied after element updates so HUD elements that rebuild their scenegraph each frame keep their customized position.
- **Crosshair-anchored widget movement** - Elements such as `HudElementWeaponCounter` that derive slot-widget positions from the crosshair can now be moved by applying the saved delta during `_draw_widgets`.
- **Ignored element persistence** - Ignored elements keep their saved settings while ignored, render at their vanilla position, and restore with their previous layout when removed from the ignore list.
- **Saved layout safety** - Saved scenegraph references are checked with `rawget` so layouts that reference disabled or missing mod elements do not trip strict-readonly scenegraph tables.
- **Scenegraph position fallback** - Applying saved positions now retries without forced `left`/`top` alignment if the first `set_scenegraph_position` call fails.
- **Panel interaction safety** - The ignore side panel consumes mouse input separately from the main element list, keeping hover, selection, and scroll state consistent when elements are ignored or restored.

### Localization

- Added English, Chinese, and Russian strings for Fixed Arrow Movement, Arrow Step, and the ignore-list panel help text.

## v2.1.2

### Features

- **Snap to Elements** — New magnetic snapping system that aligns dragged elements to nearby HUD element edges and centers (min-min, mid-mid, max-max, min-max, max-min). Toggled via settings checkbox or `/snap_to_elements` command. Respects the same Ctrl-to-invert logic as grid snapping.
- **Tactical Overlay sub-node support** — `HudElementTacticalOverlay` is no longer globally excluded. Its `background` and `canvas` scenegraphs are excluded individually, allowing other sub-nodes to be repositioned. Hide/visibility toggling correctly skips tactical overlay sub-nodes to avoid blanking the whole overlay.
- **Allowlist filtering** — Added `_allowed_scenegraphs_by_element` table to optionally whitelist specific sub-nodes per element (currently empty, ready for future use).
- **`ConstantElementExpeditionContinue`** removed from exclusion list — now customizable.

### Bug Fixes

- **Saved coords reopen fix** — Node setup now resolves position from `node_settings.position` or falls back to `{x, y, z}` fields, then merges with live `world_position`/`position` from the scenegraph. Fixes nodes losing their saved coordinates when the customizer is re-initialized.
- **Reset node preserves curated defaults** — `reset_node` no longer nils out the saved entry and forces a full rebuild. Instead it writes default values back into the existing settings and calls `_apply_node_settings_live`, preserving any custom default targets for composite/background nodes.
- **Alignment pinning** — Edit-mode overlay boxes now always use `top`/`left` alignment regardless of native node pivot. Native pivots are preserved in `default_settings` for reference but no longer cause boxes to jump or disappear during editing.
- **Persist normalization** — `_persist_saved_settings` now canonicalizes all nodes before saving: syncing `x/y/z` ↔ `position` array, stripping stale alignment fields, and clamping size components. Prevents desync across save/load cycles.
- **`_apply_node_settings_live` nil safety** — Defaults `x/y/z` to `0` and rebuilds the `position` array before applying, preventing nil propagation from partial settings.
- **`_init_node_settings` snapshots live box** — First-time init now captures the currently resolved scenegraph position/size (which may already have been moved by the game or other mods) rather than the authored definition. Makes reset behavior match what the user actually started with.
- **Tactical overlay hide safety** — `_process_widget_press_right` and `_apply_saved_node_settings` now skip setting `_is_hidden` on tactical overlay sub-nodes to prevent blanking the overlay.

### Performance

#### pcall Elimination

- **`_safe_draw_text` detect-once** — Was creating 6 closures + running up to 6 `pcall`s per invocation (~30+ calls/frame when panel visible ≈ 180 pcalls/frame). Now probes once on first call, then direct-dispatches via cached variant index. Zero pcalls after first text draw.
- **Keyboard button index cache** — `_panel_take_key` was doing 1–2 `pcall`s per key per frame during text editing. Now pcalls once per unique key name ever, caches the result (including negatives). Shared by `is_shift_held`, `is_alt_held`, `is_ctrl_held` which were previously calling uncached `kb.button_index()` multiple times per frame.

#### Allocation Elimination

- **`_get_panel_metrics` pooled** — Was allocating a 9-field table per call (2–3×/frame). Now writes into a single pooled table. Replaced per-frame `mod:get("panel_scale")` / `mod:get("panel_list_rows")` with cached locals refreshed on settings change.
- **Element snap zero-alloc** — Replaced `_element_snap_candidates` (allocated a 5-entry table-of-tables per axis per other-node during drag) with `_best_snap_axis` that returns values directly.
- **Hoisted static tables** — `_digit_keys`, `_minus_matchers`, `_period_matchers`, `_field_rows`, `_active_field_bg_color`, `_current_map_pool`, `_default_map_pool` moved to module scope from per-frame recreation inside `_handle_panel_text_input` and `_draw_info_panel`.
- **Hoisted closures** — `_prepare_buffer` and `_append_char` extracted to module-level functions from per-frame closure allocation during text editing.

### Code Quality

- Fixed forward-reference ordering for `_cached_panel_scale` / `PANEL_SCALE_DEFAULT` upvalues.
- Localization and settings data updated with `snap_to_elements` entries.
