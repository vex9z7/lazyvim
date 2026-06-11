export function Card({ title, children }) {
  return (
    <article className="card">
      <header>
        <h2>{title}</h2>
      </header>
      <div className="content">
        {children}
      </div>
    </article>
  )
}

export function App() {
  return (
    <Card title="Surround test">
      <span>Wrap or change this inline node</span>
    </Card>
  )
}
