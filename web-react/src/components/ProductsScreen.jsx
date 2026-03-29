import React, { useState, useEffect, useCallback } from 'react';
import { getProducts, createProduct, getUserStats } from '../api/chatApi';
import './ChatScreen.css';
import './ProductsScreen.css';

const ROLE_COLORS = { VENTAS:'#34d399', LOGISTICA:'#60a5fa', SOPORTE:'#fbbf24', USER:'#a78bfa' };
const fmtPrice = n => `$${parseFloat(n).toFixed(2)}`;

export default function ProductsScreen({ token, username, role, onLogout, onSwitchView }) {
  const [products,    setProducts]    = useState([]);
  const [stats,       setStats]       = useState({ product_count: 0 });
  const [loading,     setLoading]     = useState(true);
  const [formOpen,    setFormOpen]    = useState(false);
  const [submitting,  setSubmitting]  = useState(false);
  const [error,       setError]       = useState('');
  const [form,        setForm]        = useState({ name: '', description: '', price: '', stock: '' });

  const fetchAll = useCallback(async () => {
    try {
      const [prodRes, statsRes] = await Promise.all([getProducts(), getUserStats()]);
      setProducts(prodRes.data);
      setStats(statsRes.data);
    } catch {
      setError('Error al cargar productos');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  const handleCreate = async e => {
    e.preventDefault();
    if (!form.name || !form.price) return;
    setSubmitting(true);
    try {
      await createProduct({
        name:        form.name,
        description: form.description || undefined,
        price:       parseFloat(form.price),
        stock:       parseInt(form.stock, 10) || 0,
      });
      setForm({ name: '', description: '', price: '', stock: '' });
      setFormOpen(false);
      await fetchAll();
    } catch {
      setError('Error al crear producto');
    } finally {
      setSubmitting(false);
    }
  };

  const rc = ROLE_COLORS[role] || '#a78bfa';

  return (
    <div className="pr">
      {/* Sidebar (mismo estilo que ChatScreen) */}
      <aside className="cs">
        <div className="cs-logo">
          <div className="cs-logo__icon">
            <svg viewBox="0 0 32 32" fill="none">
              <path d="M16 3L28 9V23L16 29L4 23V9L16 3Z" stroke="var(--green)" strokeWidth="1.5"/>
              <path d="M16 3L16 29M4 9L28 23M28 9L4 23" stroke="var(--green)" strokeWidth=".75" strokeOpacity=".4"/>
            </svg>
          </div>
          <span className="cs-logo__text">EcoHome</span>
        </div>
        <nav className="cs-nav">
          <div className="cs-section">Vistas</div>
          <div className="cs-channel cs-channel--active">
            <svg viewBox="0 0 20 20" fill="currentColor">
              <path d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM14 11a1 1 0 011 1v1h1a1 1 0 110 2h-1v1a1 1 0 11-2 0v-1h-1a1 1 0 110-2h1v-1a1 1 0 011-1z"/>
            </svg>
            <span>Catálogo</span>
            {products.length > 0 && <span className="cs-badge">{products.length}</span>}
          </div>
          <div className="cs-channel" onClick={() => onSwitchView('chat')}>
            <svg viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2z" clipRule="evenodd"/>
            </svg>
            <span># Chat</span>
          </div>
        </nav>
        <div className="cs-user">
          <div className="cs-user__av" style={{'--ac': rc}}>{(username||'?').slice(0,2).toUpperCase()}</div>
          <div className="cs-user__info">
            <span className="cs-user__name">{username} ({stats.product_count})</span>
            <span className="cs-user__role" style={{color: rc}}>{role}</span>
          </div>
          <button className="cs-logout" onClick={onLogout} title="Cerrar sesión">
            <svg viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M3 3a1 1 0 011 1v12a1 1 0 11-2 0V4a1 1 0 011-1zm7.707 3.293a1 1 0 010 1.414L9.414 9H17a1 1 0 110 2H9.414l1.293 1.293a1 1 0 01-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0z" clipRule="evenodd"/>
            </svg>
          </button>
        </div>
      </aside>

      {/* Main */}
      <main className="pm">
        <header className="pm-header">
          <div className="pm-header__l">
            <svg className="pm-icon" viewBox="0 0 20 20" fill="currentColor">
              <path d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM14 11a1 1 0 011 1v1h1a1 1 0 110 2h-1v1a1 1 0 11-2 0v-1h-1a1 1 0 110-2h1v-1a1 1 0 011-1z"/>
            </svg>
            <h2 className="pm-title">Catálogo de Productos</h2>
            <span className="pm-desc">EcoHome Store · {username} ({stats.product_count})</span>
          </div>
          <button className="pm-add-btn" onClick={() => setFormOpen(f => !f)}>
            <svg viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clipRule="evenodd"/></svg>
            Nuevo producto
          </button>
        </header>

        {error && (
          <div className="err-banner">
            <svg viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd"/>
            </svg>
            {error}
          </div>
        )}

        {/* Formulario de creación */}
        {formOpen && (
          <form className="pm-form" onSubmit={handleCreate}>
            <div className="pm-form__title">Nuevo producto</div>
            <div className="pm-form__row">
              <div className="pm-form__field">
                <label>Nombre *</label>
                <input type="text" placeholder="Ej. EcoBotella Acero" required
                  value={form.name} onChange={e => setForm(f => ({...f, name: e.target.value}))}/>
              </div>
              <div className="pm-form__field">
                <label>Precio *</label>
                <input type="number" placeholder="0.00" min="0" step="0.01" required
                  value={form.price} onChange={e => setForm(f => ({...f, price: e.target.value}))}/>
              </div>
              <div className="pm-form__field">
                <label>Stock</label>
                <input type="number" placeholder="0" min="0"
                  value={form.stock} onChange={e => setForm(f => ({...f, stock: e.target.value}))}/>
              </div>
            </div>
            <div className="pm-form__field">
              <label>Descripción</label>
              <input type="text" placeholder="Descripción breve del producto"
                value={form.description} onChange={e => setForm(f => ({...f, description: e.target.value}))}/>
            </div>
            <div className="pm-form__actions">
              <button type="button" className="pm-cancel-btn" onClick={() => setFormOpen(false)}>Cancelar</button>
              <button type="submit" className="pm-submit-btn" disabled={submitting}>
                {submitting ? 'Creando...' : 'Crear producto'}
              </button>
            </div>
          </form>
        )}

        {/* Lista de productos */}
        <div className="pm-list">
          {loading && (
            <div className="pm-loading">
              <div className="pm-loading__spin"/>
              <span>Cargando catálogo...</span>
            </div>
          )}
          {!loading && products.length === 0 && (
            <div className="pm-empty">
              <div>📦</div>
              <p>No hay productos. ¡Crea el primero!</p>
            </div>
          )}
          {products.map(p => (
            <div key={p.id} className="pm-card">
              <div className="pm-card__body">
                <div className="pm-card__name">{p.name}</div>
                {p.description && <div className="pm-card__desc">{p.description}</div>}
                <div className="pm-card__creator">
                  <svg viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clipRule="evenodd"/>
                  </svg>
                  Creado por <strong>{p.creator_username}</strong>
                </div>
              </div>
              <div className="pm-card__meta">
                <span className="pm-card__price">{fmtPrice(p.price)}</span>
                <span className="pm-card__stock">{p.stock} en stock</span>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
