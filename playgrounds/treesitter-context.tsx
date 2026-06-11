type Product = {
  id: string
  name: string
  variants: Array<{
    id: string
    label: string
    inStock: boolean
  }>
}

export function ProductPage({ product }: { product: Product }) {
  const availableVariants = product.variants.filter((variant) => {
    if (!variant.inStock) {
      return false
    }

    return variant.label.length > 0
  })

  return (
    <main className="mx-auto max-w-3xl p-8">
      <section className="space-y-6">
        <header>
          <p className="text-sm text-slate-500">Product</p>
          <h1 className="text-3xl font-bold">{product.name}</h1>
        </header>

        <div className="grid gap-3">
          {availableVariants.map((variant) => {
            const label = `${product.name} / ${variant.label}`

            return (
              <button
                key={variant.id}
                className="rounded border border-slate-200 px-4 py-2 text-left hover:bg-slate-50"
                type="button"
              >
                <span className="block font-medium">{label}</span>
                <span className="block text-sm text-slate-500">Ships soon</span>
              </button>
            )
          })}
        </div>
      </section>
    </main>
  )
}
