type ButtonProps = {
  label: string
  onClick?: () => void
}

export function Button({ label, onClick }: ButtonProps) {
  return (
    <button className="primary" onClick={onClick}>
      <span>{label}</span>
    </button>
  )
}
