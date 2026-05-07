// Medity — primitives: backdrop, glass surfaces, status bar, buttons, icons

const M = {
  bg: '#F4F6F9',
  ink: '#0F1B2D',
  ink2: '#6B7891',
  ink3: '#A8B0BF',
  accent: '#4A6FA5',
  warm: '#C68B5C',
  warmSoft: '#E8C9A8',
  hairline: 'rgba(15,27,45,0.06)',
  hairline2: 'rgba(15,27,45,0.10)',
  glass: 'rgba(255,255,255,0.55)',
  glassDeep: 'rgba(255,255,255,0.72)',
  aura: '#C9D6E8',
  serif: '"Geist", -apple-system, system-ui, sans-serif',
  sans: '"Geist", -apple-system, system-ui, sans-serif',
  display: '"Geist", -apple-system, system-ui, sans-serif',
};

// Soft ambient backdrop with auras (used as the canvas of every screen)
function MBackdrop({ children, hue = 210, mood = 'dawn', style = {} }) {
  // mood subtly shifts color tone
  const tints = {
    dawn:  { a: '#EAE2E8', b: '#E4ECF5', c: '#F4F6F9' },
    day:   { a: '#E4ECF5', b: '#EFF3F8', c: '#F4F6F9' },
    dusk:  { a: '#E8E6F0', b: '#E2E8F0', c: '#F0F2F7' },
    night: { a: '#DDE3EE', b: '#E5EAF2', c: '#EEF1F6' },
  }[mood] || { a: '#EAE2E8', b: '#E4ECF5', c: '#F4F6F9' };
  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: `
        radial-gradient(120% 80% at 18% 8%, ${tints.a} 0%, transparent 55%),
        radial-gradient(110% 90% at 88% 24%, ${tints.b} 0%, transparent 60%),
        radial-gradient(140% 100% at 50% 110%, ${tints.b} 0%, transparent 55%),
        ${tints.c}
      `,
      ...style,
    }}>{children}</div>
  );
}

// Soft glass surface — shared recipe for cards, buttons, pills.
function MGlass({ children, radius = 24, tint = 0.55, blur = 40, border = true, inner = true, style = {}, onClick }) {
  return (
    <div onClick={onClick} style={{
      position: 'relative',
      borderRadius: radius,
      background: `rgba(255,255,255,${tint})`,
      backdropFilter: `blur(${blur}px) saturate(160%)`,
      WebkitBackdropFilter: `blur(${blur}px) saturate(160%)`,
      border: border ? '0.5px solid rgba(255,255,255,0.6)' : 'none',
      boxShadow: inner
        ? `inset 0 1px 0 rgba(255,255,255,0.7), inset 0 -1px 0 rgba(15,27,45,0.04), 0 1px 1px rgba(15,27,45,0.025), 0 8px 24px rgba(15,27,45,0.04)`
        : '0 1px 1px rgba(15,27,45,0.025), 0 8px 24px rgba(15,27,45,0.04)',
      ...style,
    }}>
      {/* outer hairline darker bottom for grounding */}
      <div style={{ position:'absolute', inset:0, borderRadius: radius, pointerEvents:'none', boxShadow:`0 0 0 0.5px ${M.hairline}` }} />
      {children}
    </div>
  );
}

// Status bar — light mode, navy ink
function MStatus({ time = '9:41' }) {
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 54,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '17px 32px 0', zIndex: 30, color: M.ink, pointerEvents: 'none',
    }}>
      <div style={{ fontFamily: M.sans, fontWeight: 600, fontSize: 17, letterSpacing: -0.2 }}>{time}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        {/* signal */}
        <svg width="18" height="11" viewBox="0 0 18 11">
          <rect x="0" y="7" width="3" height="4" rx="0.6" fill={M.ink}/>
          <rect x="4.5" y="5" width="3" height="6" rx="0.6" fill={M.ink}/>
          <rect x="9" y="2.5" width="3" height="8.5" rx="0.6" fill={M.ink}/>
          <rect x="13.5" y="0" width="3" height="11" rx="0.6" fill={M.ink}/>
        </svg>
        {/* wifi */}
        <svg width="16" height="11" viewBox="0 0 16 11">
          <path d="M8 2.8C10.1 2.8 12 3.6 13.4 5L14.4 4C12.7 2.3 10.4 1.2 8 1.2C5.6 1.2 3.3 2.3 1.6 4L2.6 5C4 3.6 5.9 2.8 8 2.8Z" fill={M.ink}/>
          <path d="M8 6.1C9.3 6.1 10.4 6.6 11.2 7.4L12.2 6.4C11 5.3 9.6 4.5 8 4.5C6.4 4.5 5 5.3 3.8 6.4L4.8 7.4C5.6 6.6 6.7 6.1 8 6.1Z" fill={M.ink}/>
          <circle cx="8" cy="9.6" r="1.4" fill={M.ink}/>
        </svg>
        {/* battery */}
        <svg width="25" height="12" viewBox="0 0 25 12">
          <rect x="0.5" y="0.5" width="21" height="11" rx="3" stroke={M.ink} strokeOpacity="0.4" fill="none"/>
          <rect x="2" y="2" width="18" height="8" rx="1.6" fill={M.ink}/>
          <path d="M23 4V8C23.7 7.7 24.2 7 24.2 6C24.2 5 23.7 4.3 23 4Z" fill={M.ink} fillOpacity="0.4"/>
        </svg>
      </div>
    </div>
  );
}

// Dynamic island with optional Live Activity content
function MIsland({ children, expanded = false }) {
  if (expanded) {
    return (
      <div style={{
        position:'absolute', top: 11, left:'50%', transform:'translateX(-50%)',
        width: 360, height: 116, borderRadius: 44, background:'#0A0F18',
        zIndex: 50, padding: 14, boxSizing:'border-box', color:'#fff',
        boxShadow:'0 12px 36px rgba(10,15,24,0.45)',
      }}>{children}</div>
    );
  }
  return (
    <div style={{
      position:'absolute', top: 11, left:'50%', transform:'translateX(-50%)',
      minWidth: 126, height: 37, borderRadius: 24, background:'#0A0F18',
      zIndex: 50, display:'flex', alignItems:'center', justifyContent:'center',
      padding: '0 12px', color:'#fff', fontFamily: M.sans, fontSize: 13, gap: 8,
    }}>{children}</div>
  );
}

// Phone frame — overrides IOSDevice styling for our light palette
function MPhone({ children, w = 393, h = 852, mood = 'dawn', islandContent = null, islandExpanded = false }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: 54, position: 'relative',
      overflow: 'hidden',
      background: M.bg,
      boxShadow: '0 50px 100px rgba(15,27,45,0.18), 0 0 0 1px rgba(15,27,45,0.10), inset 0 0 0 6px #1a1f28',
      fontFamily: M.sans,
      WebkitFontSmoothing: 'antialiased',
    }}>
      <div style={{ position: 'absolute', inset: 6, borderRadius: 48, overflow: 'hidden', background: M.bg }}>
        <MBackdrop mood={mood}>{null}</MBackdrop>
        <MStatus />
        <MIsland expanded={islandExpanded}>{islandContent}</MIsland>
        {/* home indicator */}
        <div style={{
          position:'absolute', bottom: 8, left:0, right:0, height: 5,
          display:'flex', justifyContent:'center', zIndex: 60,
          pointerEvents:'none',
        }}>
          <div style={{ width: 134, height: 5, borderRadius: 100, background: 'rgba(15,27,45,0.35)' }} />
        </div>
        <div style={{ position:'absolute', inset: 0 }}>{children}</div>
      </div>
    </div>
  );
}

// A pill button (glass)
function MPill({ children, style = {}, onClick, dark = false }) {
  return (
    <MGlass radius={9999} tint={dark ? 0.75 : 0.55} blur={30} style={{
      display:'inline-flex', alignItems:'center', justifyContent:'center',
      padding: '12px 18px',
      ...style,
    }}>
      <div style={{ display:'flex', alignItems:'center', gap: 10, color: M.ink, fontFamily: M.sans, fontSize: 15, fontWeight: 500, letterSpacing: -0.1 }}>
        {children}
      </div>
    </MGlass>
  );
}

// A primary glass button (full width) — icon-led
function MPrimaryButton({ children, icon = 'play', style = {} }) {
  const ic = icon === 'play' ? (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <path d="M5 3.5l9 5.5-9 5.5z" fill={M.ink}/>
    </svg>
  ) : icon === 'arrow' ? (
    <svg width="18" height="14" viewBox="0 0 18 14" fill="none">
      <path d="M2 7h13M11 2l5 5-5 5" stroke={M.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ) : icon;
  return (
    <MGlass radius={9999} tint={0.65} blur={40} style={{
      display:'flex', alignItems:'center', justifyContent:'center', gap: 14,
      height: 64, ...style,
    }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap: 14, position:'relative', zIndex: 1 }}>
        <span style={{
          fontFamily: M.sans, fontSize: 17, fontWeight: 500,
          color: M.ink, letterSpacing: 0.2,
        }}>{children}</span>
        <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'rgba(15,27,45,0.06)', display:'flex', alignItems:'center', justifyContent:'center' }}>
          {ic}
        </div>
      </div>
    </MGlass>
  );
}

// Soft aura behind the timer
function MAura({ size = 360, intensity = 1, hue = M.aura, style = {} }) {
  return (
    <div style={{
      width: size, height: size, position:'absolute',
      borderRadius: '50%',
      background: `radial-gradient(circle, ${hue} 0%, ${hue}88 35%, transparent 70%)`,
      filter: 'blur(40px)',
      opacity: 0.75 * intensity,
      pointerEvents:'none',
      ...style,
    }}/>
  );
}

// Annotation chip — dashed line + caption to call out animations / behaviours
function MAnnotation({ x, y, w = 180, side = 'right', label, sub }) {
  const isRight = side === 'right';
  return (
    <div style={{
      position: 'absolute', left: x, top: y, width: w, zIndex: 100,
      pointerEvents: 'none',
      display:'flex', flexDirection: isRight ? 'row' : 'row-reverse', alignItems:'center', gap: 10,
    }}>
      <div style={{
        flex: 1, borderTop: '1px dashed #b6a89a', height: 1,
      }}/>
      <div style={{
        background: 'rgba(255,250,242,0.92)',
        border: '1px solid #d6c7b3',
        borderRadius: 4, padding: '7px 10px',
        fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace',
        fontSize: 10, color: '#5a4a2a', lineHeight: 1.35,
        boxShadow: '0 4px 16px rgba(90,74,42,0.12)',
        whiteSpace: 'nowrap',
      }}>
        <div style={{ fontWeight: 600 }}>{label}</div>
        {sub && <div style={{ color:'#8a7a52', fontSize: 9.5, marginTop: 2 }}>{sub}</div>}
      </div>
    </div>
  );
}

// Common icons (line)
const Icons = {
  settings: (c = M.ink) => (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <circle cx="10" cy="10" r="2.5" stroke={c} strokeWidth="1.4"/>
      <path d="M10 1.5v2M10 16.5v2M3.5 3.5l1.4 1.4M15.1 15.1l1.4 1.4M1.5 10h2M16.5 10h2M3.5 16.5l1.4-1.4M15.1 4.9l1.4-1.4" stroke={c} strokeWidth="1.4" strokeLinecap="round"/>
    </svg>
  ),
  stats: (c = M.ink) => (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <path d="M3 17V8M9 17V3M15 17v-7" stroke={c} strokeWidth="1.4" strokeLinecap="round"/>
    </svg>
  ),
  close: (c = M.ink) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
      <path d="M2 2l10 10M12 2L2 12" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  pause: (c = M.ink) => (
    <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
      <rect x="6" y="4" width="3" height="14" rx="1.2" fill={c}/>
      <rect x="13" y="4" width="3" height="14" rx="1.2" fill={c}/>
    </svg>
  ),
  play: (c = M.ink) => (
    <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
      <path d="M6 4l12 7-12 7V4z" fill={c}/>
    </svg>
  ),
  bell: (c = M.ink) => (
    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
      <path d="M9 1.5v1.2M4.5 7.5C4.5 5 6.5 3 9 3s4.5 2 4.5 4.5v3l1.5 2.5h-12l1.5-2.5v-3z" stroke={c} strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M7.5 14.5c0 .8.7 1.5 1.5 1.5s1.5-.7 1.5-1.5" stroke={c} strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  ),
  wave: (c = M.ink) => (
    <svg width="18" height="14" viewBox="0 0 18 14" fill="none">
      <path d="M1 7c2-3 3-3 5 0s3 3 5 0 3-3 5 0" stroke={c} strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  ),
  lock: (c = M.ink3) => (
    <svg width="13" height="14" viewBox="0 0 13 14" fill="none">
      <rect x="2" y="6" width="9" height="7" rx="1.4" stroke={c} strokeWidth="1.2"/>
      <path d="M4 6V4a2.5 2.5 0 015 0v2" stroke={c} strokeWidth="1.2"/>
    </svg>
  ),
  check: (c = M.accent) => (
    <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
      <path d="M2.5 7.5l3 3 6-6" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  chevron: (c = M.ink3) => (
    <svg width="7" height="12" viewBox="0 0 7 12" fill="none">
      <path d="M1 1l5 5-5 5" stroke={c} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  flame: (c = M.accent) => (
    <svg width="16" height="20" viewBox="0 0 16 20" fill="none">
      <path d="M8 1c0 4-5 5-5 11a5 5 0 0010 0c0-3-2-4-2-7 0 0-3 1-3 4 0-3 0-5 0-8z" stroke={c} strokeWidth="1.3" strokeLinejoin="round"/>
    </svg>
  ),
  arrow: (c = M.ink) => (
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
      <path d="M3 8h10M9 4l4 4-4 4" stroke={c} strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
};

Object.assign(window, {
  M, MBackdrop, MGlass, MStatus, MIsland, MPhone, MPill, MPrimaryButton, MAura, MAnnotation, Icons,
});
