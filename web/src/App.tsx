import { useState } from 'react';
import { infixToPostfix, normalizeExpression } from './algorithms/shunting-yard';

import ThompsonConstruction from './ThompsonConstruction';

function App() {
  const [regex, setRegex] = useState<string>("");

  return (
    <div className="p-2">
      <div className="flex items-center gap-2">
        <div>Regular Expression</div>
        <input type="text" className="border rounded-xl px-3" value={regex} onChange={event => setRegex(event.currentTarget.value)} />
      </div>
      <ThompsonConstruction postfixExpression={infixToPostfix(normalizeExpression(regex))} />
    </div>
  )
}

export default App
