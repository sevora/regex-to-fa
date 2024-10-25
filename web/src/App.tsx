import { useState } from 'react';

function App() {
  const [regex, setRegex] = useState<string>("");

  return (
    <div>
      <input type="text" value={regex} onChange={event => setRegex(event.currentTarget.value)} />
    </div>
  )
}

export default App
