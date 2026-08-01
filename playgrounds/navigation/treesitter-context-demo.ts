export class CheckoutService {
  async createCheckout(userId: string, items: Array<{ sku: string; quantity: number }>) {
    const normalizedItems = items.map((item) => {
      return {
        sku: item.sku.trim().toUpperCase(),
        quantity: Math.max(1, item.quantity),
      }
    })

    for (const item of normalizedItems) {
      if (item.quantity > 10) {
        await this.reserveBulkInventory(userId, item.sku, item.quantity)
      } else {
        await this.reserveInventory(userId, item.sku, item.quantity)
      }
    }

    return {
      userId,
      items: normalizedItems,
      status: "created",
    }
  }

  async auditCheckout(userId: string, items: Array<{ sku: string; quantity: number }>) {
    const report = {
      userId,
      sections: [] as string[],
    }

    for (const item of items) {
      if (item.quantity > 0) {
        for (const warehouse of ["primary", "secondary", "overflow"]) {
          if (warehouse === "primary") {
            report.sections.push(`${warehouse}:${item.sku}:fast-path`)
          } else {
            report.sections.push(`${warehouse}:${item.sku}:fallback-path`)
          }
        }
      }
    }

    return report
  }

  private async reserveBulkInventory(userId: string, sku: string, quantity: number) {
    if (!userId) {
      throw new Error("missing user")
    }

    if (!sku) {
      throw new Error("missing sku")
    }

    return {
      userId,
      sku,
      quantity,
      reserved: true,
    }
  }

  private async reserveInventory(userId: string, sku: string, quantity: number) {
    return this.reserveBulkInventory(userId, sku, quantity)
  }
}

// filler line 1: scroll until the class/function header leaves the window
// filler line 2: scroll until the class/function header leaves the window
// filler line 3: scroll until the class/function header leaves the window
// filler line 4: scroll until the class/function header leaves the window
// filler line 5: scroll until the class/function header leaves the window
// filler line 6: scroll until the class/function header leaves the window
// filler line 7: scroll until the class/function header leaves the window
// filler line 8: scroll until the class/function header leaves the window
// filler line 9: scroll until the class/function header leaves the window
// filler line 10: scroll until the class/function header leaves the window
// filler line 11: scroll until the class/function header leaves the window
// filler line 12: scroll until the class/function header leaves the window
// filler line 13: scroll until the class/function header leaves the window
// filler line 14: scroll until the class/function header leaves the window
// filler line 15: scroll until the class/function header leaves the window
// filler line 16: scroll until the class/function header leaves the window
// filler line 17: scroll until the class/function header leaves the window
// filler line 18: scroll until the class/function header leaves the window
// filler line 19: scroll until the class/function header leaves the window
// filler line 20: scroll until the class/function header leaves the window
// filler line 21: scroll until the class/function header leaves the window
// filler line 22: scroll until the class/function header leaves the window
// filler line 23: scroll until the class/function header leaves the window
// filler line 24: scroll until the class/function header leaves the window
// filler line 25: scroll until the class/function header leaves the window
// filler line 26: scroll until the class/function header leaves the window
// filler line 27: scroll until the class/function header leaves the window
// filler line 28: scroll until the class/function header leaves the window
// filler line 29: scroll until the class/function header leaves the window
// filler line 30: scroll until the class/function header leaves the window
// filler line 31: scroll until the class/function header leaves the window
// filler line 32: scroll until the class/function header leaves the window
// filler line 33: scroll until the class/function header leaves the window
// filler line 34: scroll until the class/function header leaves the window
// filler line 35: scroll until the class/function header leaves the window
// filler line 36: scroll until the class/function header leaves the window
// filler line 37: scroll until the class/function header leaves the window
// filler line 38: scroll until the class/function header leaves the window
// filler line 39: scroll until the class/function header leaves the window
// filler line 40: scroll until the class/function header leaves the window
