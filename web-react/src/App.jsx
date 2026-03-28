import React, { useState, useCallback } from 'react';
const Login          = React.lazy(() => import('./components/Login'));
const ChatScreen     = React.lazy(() => import('./components/ChatScreen'));
const ProductsScreen = React.lazy(() => import('./components/ProductsScreen'));

export default function App() {
  const [token,    setToken]    = useState(() => localStorage.getItem('token'));
  const [username, setUsername] = useState(() => localStorage.getItem('username'));
  const [role,     setRole]     = useState(() => localStorage.getItem('role'));
  const [view,     setView]     = useState('products'); // 'products' | 'chat'

  const handleSuccess = useCallback(() => {
    setToken(localStorage.getItem('token'));
    setUsername(localStorage.getItem('username'));
    setRole(localStorage.getItem('role'));
    setView('products');
  }, []);

  const handleLogout = useCallback(() => {
    localStorage.clear();
    setToken(null); setUsername(null); setRole(null);
  }, []);

  return (
    <React.Suspense fallback={
      <div style={{height:'100vh',display:'flex',alignItems:'center',justifyContent:'center',background:'var(--bg-base)'}}>
        <div style={{width:24,height:24,border:'2px solid var(--border)',borderTopColor:'var(--green)',borderRadius:'50%',animation:'spin .8s linear infinite'}}/>
      </div>
    }>
      {!token
        ? <Login onSuccess={handleSuccess}/>
        : view === 'chat'
          ? <ChatScreen     token={token} username={username} role={role} onLogout={handleLogout} onSwitchView={setView}/>
          : <ProductsScreen token={token} username={username} role={role} onLogout={handleLogout} onSwitchView={setView}/>
      }
    </React.Suspense>
  );
}
