import React, { useState, useEffect, useRef } from 'react';
import { useSocket } from '../hooks/useSocket';
import './ChatScreen.css';

const ROLE_COLORS = { VENTAS:'#34d399', LOGISTICA:'#60a5fa', SOPORTE:'#fbbf24', USER:'#a78bfa' };
const fmt = dt => dt ? new Date(dt).toLocaleTimeString('es-CO',{hour:'2-digit',minute:'2-digit'}) : '';
const fmtDate = dt => {
  if (!dt) return '';
  const d = new Date(dt), today = new Date();
  if (d.toDateString()===today.toDateString()) return 'Hoy';
  const y = new Date(today); y.setDate(today.getDate()-1);
  if (d.toDateString()===y.toDateString()) return 'Ayer';
  return d.toLocaleDateString('es-CO',{day:'numeric',month:'long'});
};

function Avatar({ username, role }) {
  return <div className="avatar" style={{'--ac': ROLE_COLORS[role]||'#a78bfa'}}>{(username||'?').slice(0,2).toUpperCase()}</div>;
}

function Bubble({ msg, isOwn, showAvatar }) {
  return (
    <div className={`msg ${isOwn?'msg--own':'msg--other'} ${showAvatar?'msg--first':''}`}>
      {!isOwn && (showAvatar ? <Avatar username={msg.username} role={msg.role}/> : <div className="msg__spacer"/>)}
      <div className="msg__body">
        {!isOwn && showAvatar && <span className="msg__user" style={{color:ROLE_COLORS[msg.role]||'var(--text-secondary)'}}>{msg.username}</span>}
        <div className="msg__bubble">
          <span className="msg__text">{msg.text}</span>
          <span className="msg__time">{fmt(msg.createdAt)}</span>
        </div>
      </div>
    </div>
  );
}

export default function ChatScreen({ token, username, role, onLogout, onSwitchView }) {
  const [input, setInput] = useState('');
  const { messages, connected, error, sendMessage } = useSocket(token);
  const bottomRef = useRef(null);
  const inputRef  = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior:'smooth' }); }, [messages]);

  const handleSend = e => {
    e.preventDefault();
    if (!input.trim() || !connected) return;
    sendMessage(input.trim());
    setInput('');
    inputRef.current?.focus();
  };

  // Agrupar con separadores de fecha
  const items = messages.reduce((acc, msg, i) => {
    const ds = fmtDate(msg.createdAt);
    const ps = i>0 ? fmtDate(messages[i-1].createdAt) : null;
    if (ds !== ps) acc.push({ type:'divider', date:ds });
    acc.push({ type:'msg', msg, showAvatar: i===0 || messages[i-1].username!==msg.username });
    return acc;
  }, []);

  const rc = ROLE_COLORS[role]||'#a78bfa';
  return (
    <div className="cr">
      {/* Sidebar */}
      <aside className="cs">
        <div className="cs-logo">
          <div className="cs-logo__icon"><svg viewBox="0 0 32 32" fill="none"><path d="M16 3L28 9V23L16 29L4 23V9L16 3Z" stroke="var(--green)" strokeWidth="1.5"/><path d="M16 3L16 29M4 9L28 23M28 9L4 23" stroke="var(--green)" strokeWidth=".75" strokeOpacity=".4"/></svg></div>
          <span className="cs-logo__text">EcoHome</span>
        </div>
        <nav className="cs-nav">
          <div className="cs-section">Vistas</div>
          <div className="cs-channel" onClick={() => onSwitchView?.('products')}>
            <svg viewBox="0 0 20 20" fill="currentColor">
              <path d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM14 11a1 1 0 011 1v1h1a1 1 0 110 2h-1v1a1 1 0 11-2 0v-1h-1a1 1 0 110-2h1v-1a1 1 0 011-1z"/>
            </svg>
            <span>Catálogo</span>
          </div>
          <div className="cs-section" style={{marginTop:8}}>Canales</div>
          <div className="cs-channel cs-channel--active">
            <svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zM7 8H5v2h2V8zm2 0h2v2H9V8zm6 0h-2v2h2V8z" clipRule="evenodd"/></svg>
            <span># general</span>
            {messages.length>0 && <span className="cs-badge">{messages.length}</span>}
          </div>
        </nav>
        <div className="cs-user">
          <div className="cs-user__av" style={{'--ac':rc}}>{(username||'?').slice(0,2).toUpperCase()}</div>
          <div className="cs-user__info">
            <span className="cs-user__name">{username}</span>
            <span className="cs-user__role" style={{color:rc}}>{role}</span>
          </div>
          <button className="cs-logout" onClick={onLogout} title="Cerrar sesión">
            <svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M3 3a1 1 0 011 1v12a1 1 0 11-2 0V4a1 1 0 011-1zm7.707 3.293a1 1 0 010 1.414L9.414 9H17a1 1 0 110 2H9.414l1.293 1.293a1 1 0 01-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0z" clipRule="evenodd"/></svg>
          </button>
        </div>
      </aside>

      {/* Main */}
      <main className="cm">
        <header className="cm-header">
          <div className="cm-header__l">
            <svg className="cm-hash" viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M9.243 3.03a1 1 0 01.727 1.213L9.53 6h2.94l.56-2.243a1 1 0 111.94.486L14.53 6H17a1 1 0 110 2h-2.97l-1 4H15a1 1 0 110 2h-2.47l-.56 2.242a1 1 0 11-1.94-.485L10.47 14H7.53l-.56 2.242a1 1 0 11-1.94-.485L5.47 14H3a1 1 0 110-2h2.97l1-4H5a1 1 0 110-2h2.47l.56-2.243a1 1 0 011.213-.727zM9.03 8l-1 4h2.938l1-4H9.031z" clipRule="evenodd"/></svg>
            <h2 className="cm-title">general</h2>
            <span className="cm-desc">Canal de coordinación · EcoHome Store</span>
          </div>
          <div className={`status-pill ${connected?'status-pill--on':'status-pill--off'}`}>
            <span className="status-dot"/>
            {connected ? 'Conectado' : 'Reconectando...'}
          </div>
        </header>

        {error && <div className="err-banner"><svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd"/></svg>{error}</div>}

        <div className="msgs">
          {messages.length===0 && connected && <div className="msgs-empty"><div>💬</div><p>No hay mensajes aún. ¡Sé el primero!</p></div>}
          {!connected && messages.length===0 && <div className="msgs-conn"><div className="msgs-conn__spin"/><span>Conectando...</span></div>}
          {items.map((it,i) =>
            it.type==='divider'
              ? <div key={`d${i}`} className="date-div"><span>{it.date}</span></div>
              : <Bubble key={it.msg.id||`t${i}`} msg={it.msg} isOwn={it.msg.username===username} showAvatar={it.showAvatar}/>
          )}
          <div ref={bottomRef}/>
        </div>

        <div className="input-area">
          <form className="input-form" onSubmit={handleSend}>
            <input ref={inputRef} className="chat-input" type="text"
              placeholder={connected?'Mensaje en #general...':'Esperando conexión...'}
              value={input} onChange={e=>setInput(e.target.value)}
              onKeyDown={e=>e.key==='Enter'&&!e.shiftKey&&handleSend(e)}
              disabled={!connected} maxLength={2000} autoComplete="off"/>
            <div className="input-actions">
              <span className="input-count">{input.length}/2000</span>
              <button type="submit" className="send-btn" disabled={!connected||!input.trim()}>
                <svg viewBox="0 0 20 20" fill="currentColor"><path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z"/></svg>
              </button>
            </div>
          </form>
        </div>
      </main>
    </div>
  );
}
