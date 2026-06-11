export function ColorPreview() {
  return (
    <section className="bg-blue-500 text-white border border-slate-200">
      <div className="from-purple-500 to-pink-500 bg-gradient-to-r">
        Tailwind color classes should show virtual swatches.
      </div>
      <div className="bg-[#1da1f2] text-[rgb(255,255,255)] border-[hsl(150deg_30%_40%)]">
        Arbitrary Tailwind colors should also be visible.
      </div>
      <style>{`
        .brand {
          color: #12abef;
          background: hsl(220deg 14% 96%);
        }
      `}</style>
    </section>
  )
}
