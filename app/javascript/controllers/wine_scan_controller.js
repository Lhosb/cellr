import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "image",
    "status",
    "winery",
    "wineName",
    "vintage",
    "varietal",
    "wineType",
    "region",
    "bottleSizeMl",
  ];
  static values = { endpoint: String };

  async scan() {
    if (!this.hasImageTarget || this.imageTarget.files.length === 0) {
      this.setStatus("Choose an image first.");
      return;
    }

    const formData = new FormData();
    formData.append("image", this.imageTarget.files[0]);

    this.setStatus("Scanning bottle…");

    try {
      const response = await fetch(this.endpointValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken,
          Accept: "application/json",
        },
        body: formData,
      });

      const payload = await response.json();

      if (!response.ok) {
        this.setStatus(payload.error || "Bottle scan failed.");
        return;
      }

      this.assign(this.wineryTarget, payload.winery);
      this.assign(this.wineNameTarget, payload.wine_name);
      this.assign(this.vintageTarget, payload.vintage);
      this.assign(this.varietalTarget, payload.varietal);
      this.assign(this.wineTypeTarget, payload.wine_type);
      this.assign(this.regionTarget, payload.region);
      this.assign(this.bottleSizeMlTarget, payload.bottle_size_ml);

      this.setStatus("Bottle scanned. Review fields before saving.");
    } catch (_error) {
      this.setStatus("Bottle scan failed.");
    } finally {
      this.imageTarget.value = "";
    }
  }

  async imageSelected(event) {
    if (!event.target.files || event.target.files.length === 0) {
      return;
    }

    this.setStatus("Scanning bottle…");
    await this.scan();
  }

  assign(target, value) {
    if (value === null || value === undefined || value === "") {
      return;
    }

    target.value = value;
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || "";
  }
}
