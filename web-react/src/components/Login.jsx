import React, { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import './Login.css';

const ROLES = ['VENTAS','LOGISTICA','SOPORTE','USER'];

export default function Login({ onSuccess }) {
  const [mode,     setMode]     = useState('login');
  const [username, setUsername] = useState('');
  const [email,    setEmail]    = useState('');
  const [password, setPassword] = useState('');
  const [role,     setRole]     = useState('USER');
  const [showPass, setShowPass] = useState(false);
  const { loading, error, login, register } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (mode === 'login') {
      const ok = await login(username, password);
      if (ok) onSuccess();
    } else {
      const ok = await register(username, email, password, role);
      if (ok) { setMode('login'); setPassword(''); }
    }
  };

  return (
    <div className="login-root">
      <div className="login-bg">
        <div className="login-bg__orb login-bg__orb--1"/>
        <div className="login-bg__orb login-bg__orb--2"/>
        <div className="login-bg__grid"/>
      </div>
      <div className="login-card">
        <div className="login-brand">
          <div className="login-brand__icon">
            <svg viewBox="0 0 32 32" fill="none"><path d="M16 3L28 9V23L16 29L4 23V9L16 3Z" stroke="var(--green)" strokeWidth="1.5"/><path d="M16 3L16 29M4 9L28 23M28 9L4 23" stroke="var(--green)" strokeWidth=".75" strokeOpacity=".4"/></svg>
          </div>
          <div>
            <h1 className="login-brand__name">EcoHome</h1>
            <p className="login-brand__sub">Chat Interno Corporativo</p>
          </div>
        </div>

        <div className="login-tabs">
          <button className={`login-tab${mode==='login'?' active':''}`} onClick={()=>setMode('login')}>Ingresar</button>
          <button className={`login-tab${mode==='register'?' active':''}`} onClick={()=>setMode('register')}>Registrar</button>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          <div className="login-field">
            <label className="login-label">Usuario</label>
            <div className="login-input-wrap">
              <span className="login-input-icon"><svg viewBox="0 0 20 20" fill="currentColor"><path d="M10 10a4 4 0 100-8 4 4 0 000 8zm-7 8a7 7 0 1114 0H3z"/></svg></span>
              <input className="login-input" type="text" placeholder="tu_usuario" value={username} onChange={e=>setUsername(e.target.value)} required autoFocus/>
            </div>
          </div>

          {mode==='register' && (
            <div className="login-field">
              <label className="login-label">Email</label>
              <div className="login-input-wrap">
                <span className="login-input-icon"><svg viewBox="0 0 20 20" fill="currentColor"><path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"/><path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"/></svg></span>
                <input className="login-input" type="email" placeholder="email@ecohome.co" value={email} onChange={e=>setEmail(e.target.value)} required/>
              </div>
            </div>
          )}

          <div className="login-field">
            <label className="login-label">Contraseña</label>
            <div className="login-input-wrap">
              <span className="login-input-icon"><svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd"/></svg></span>
              <input className="login-input" type={showPass?'text':'password'} placeholder="••••••••" value={password} onChange={e=>setPassword(e.target.value)} required/>
              <button type="button" className="login-eye" onClick={()=>setShowPass(v=>!v)}>
                <svg viewBox="0 0 20 20" fill="currentColor"><path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/><path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd"/></svg>
              </button>
            </div>
          </div>

          {mode==='register' && (
            <div className="login-field">
              <label className="login-label">Equipo</label>
              <div className="login-input-wrap">
                <span className="login-input-icon"><svg viewBox="0 0 20 20" fill="currentColor"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v1h8v-1zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-1a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v1h-3zM4.75 12.094A5.973 5.973 0 004 15v1H1v-1a3 3 0 013.75-2.906z"/></svg></span>
                <select className="login-input login-select" value={role} onChange={e=>setRole(e.target.value)}>
                  {ROLES.map(r=><option key={r} value={r}>{r}</option>)}
                </select>
              </div>
            </div>
          )}

          {error && (
            <div className="login-error">
              <svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd"/></svg>
              <span>{error}</span>
            </div>
          )}

          <button className="login-btn" type="submit" disabled={loading}>
            {loading ? <span className="login-btn__spinner"/> : mode==='login' ? 'Ingresar al chat' : 'Crear cuenta'}
          </button>
        </form>

        {mode==='login' && (
          <p className="login-hint">
            Cuentas de prueba: <strong>ventas_admin</strong>, <strong>logistica_op</strong>, <strong>soporte_01</strong><br/>
            Contraseña: <strong>password123</strong>
          </p>
        )}
      </div>
    </div>
  );
}
