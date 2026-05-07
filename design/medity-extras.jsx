// Screens 11-12 + extras: Settings, Paywall, Widgets, Live Activity, Style Guide, App Icon

// ─────────────────────────────────────────────────────────────
// 11 — Settings
// ─────────────────────────────────────────────────────────────
function SetRow({ label, detail, toggle, last, chevron, accent }) {
  return (
    <div style={{ display:'flex', alignItems:'center', padding:'14px 18px',
      borderBottom: last ? 'none' : `0.5px solid ${M.hairline}`,
      minHeight: 44,
    }}>
      <div style={{ flex: 1, fontSize: 16, color: accent ? M.accent : M.ink }}>{label}</div>
      {detail && <div style={{ fontSize: 15, color: M.ink2, marginRight: chevron ? 8 : 0 }}>{detail}</div>}
      {toggle !== undefined && (
        <div style={{ width: 51, height: 31, borderRadius: 100, background: toggle ? M.accent : 'rgba(15,27,45,0.12)', position:'relative', transition:'all .2s' }}>
          <div style={{ position:'absolute', top: 2, [toggle ? 'right' : 'left']: 2, width: 27, height: 27, borderRadius:'50%', background:'#fff', boxShadow:'0 2px 4px rgba(0,0,0,0.15)' }}/>
        </div>
      )}
      {chevron && <div style={{ marginLeft: 4 }}>{Icons.chevron()}</div>}
    </div>
  );
}

function SetGroup({ header, children, footer }) {
  return (
    <div style={{ marginTop: 24 }}>
      {header && <div style={{ fontSize: 11, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase', padding:'0 22px 8px' }}>{header}</div>}
      <MGlass radius={20} tint={0.55} style={{ margin:'0 14px' }}>
        <div style={{ position:'relative', zIndex:1 }}>{children}</div>
      </MGlass>
      {footer && <div style={{ fontSize: 12, color: M.ink3, padding:'10px 22px 0', lineHeight: 1.4 }}>{footer}</div>}
    </div>
  );
}

function ScreenSettings() {
  return (
    <MPhone mood="day">
      <div style={{ position:'absolute', top: 60, left: 0, right: 0, padding:'0 20px', display:'flex', justifyContent:'space-between', zIndex: 10 }}>
        <div style={{ width: 44 }}/>
        <div className="serif" style={{ fontSize: 18, color: M.ink, alignSelf:'center' }}>Settings</div>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <div style={{ position:'relative', zIndex:1 }}>{Icons.close()}</div>
        </MGlass>
      </div>

      <div style={{ position:'absolute', top: 116, left: 0, right: 0, bottom: 36, overflowY:'auto', paddingBottom: 20 }}>
        <SetGroup header="Reminder">
          <SetRow label="Daily reminder" toggle={true}/>
          <SetRow label="At" detail="6:30 am" chevron/>
          <SetRow label="Days" detail="Mon–Fri" chevron last/>
        </SetGroup>

        <SetGroup header="Defaults">
          <SetRow label="Duration" detail="20 min" chevron/>
          <SetRow label="Sound" detail="Rain · Light" chevron/>
          <SetRow label="Bells" detail="Start & End" chevron last/>
        </SetGroup>

        <SetGroup header="Health & sync" footer="Sessions are written to Apple Health as Mindful Minutes.">
          <SetRow label="Apple Health" toggle={true}/>
          <SetRow label="iCloud sync" detail="Up to date" last/>
        </SetGroup>

        <SetGroup header="Medity Plus">
          <SetRow label="Restore purchases" accent/>
          <SetRow label="Unlock Medity Plus" detail="€14.99" accent chevron last/>
        </SetGroup>

        <SetGroup header="About">
          <SetRow label="Privacy"  chevron/>
          <SetRow label="Acknowledgements" chevron/>
          <SetRow label="Version" detail="1.0 · 2026" last/>
        </SetGroup>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// 12 — Paywall
// ─────────────────────────────────────────────────────────────
function ScreenPaywall() {
  const benefits = [
    { name: 'All sounds', sub: '14 nature, sacred, and noise tracks.', icon: <svg width="22" height="22" viewBox="0 0 22 22"><path d="M3 11c2-4 3-4 5 0s3 4 5 0 3-4 5 0" stroke={M.ink} strokeWidth="1.2" fill="none" strokeLinecap="round"/></svg> },
    { name: 'All bells', sub: '6 bell timbres, custom intervals.', icon: <svg width="22" height="22" viewBox="0 0 22 22"><path d="M11 2v1.4M5.5 9C5.5 6.5 8 4 11 4s5.5 2.5 5.5 5.5v3l1.5 2.5H4l1.5-2.5z M9 18a2 2 0 004 0" stroke={M.ink} strokeWidth="1.2" fill="none" strokeLinejoin="round" strokeLinecap="round"/></svg> },
    { name: 'All themes', sub: 'Dawn, Dusk, Twilight, Monastery.', icon: <svg width="22" height="22" viewBox="0 0 22 22"><circle cx="11" cy="11" r="6" stroke={M.ink} strokeWidth="1.2" fill="none"/><path d="M11 1v3M11 18v3M1 11h3M18 11h3" stroke={M.ink} strokeWidth="1.2" strokeLinecap="round"/></svg> },
    { name: 'Future updates', sub: 'New sounds and themes, on us.', icon: <svg width="22" height="22" viewBox="0 0 22 22"><path d="M11 6v6l4 2M11 1a10 10 0 110 20 10 10 0 010-20z" stroke={M.ink} strokeWidth="1.2" fill="none" strokeLinecap="round"/></svg> },
  ];
  return (
    <MPhone mood="dusk">
      <div style={{ position:'absolute', top: 60, right: 20, zIndex: 10 }}>
        <MGlass radius={22} tint={0.55} style={{ width: 44, height: 44, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <div style={{ position:'relative', zIndex:1 }}>{Icons.close()}</div>
        </MGlass>
      </div>

      <div style={{ position:'absolute', inset: 0, padding:'128px 28px 0', display:'flex', flexDirection:'column' }}>
        <MAura size={300} style={{ top: 80, left:'50%', transform:'translateX(-50%)' }}/>
        <div className="serif" style={{ fontSize: 60, color: M.ink, lineHeight: 0.95, fontWeight: 300, letterSpacing: -1.5 }}>Go<br/>deeper.</div>
        <div style={{ marginTop: 14, fontFamily: M.serif, fontStyle:'italic', fontSize: 17, color: M.ink2, lineHeight: 1.5, maxWidth: 280 }}>
          Medity Plus opens the rest of the library. One time, no subscription.
        </div>

        <div style={{ marginTop: 36, display:'flex', flexDirection:'column', gap: 22 }}>
          {benefits.map(b => (
            <div key={b.name} style={{ display:'flex', alignItems:'flex-start', gap: 16 }}>
              <div style={{ width: 38, height: 38, borderRadius: 12, background:'rgba(255,255,255,0.5)', border:`0.5px solid ${M.hairline}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink: 0 }}>{b.icon}</div>
              <div>
                <div className="serif" style={{ fontSize: 18, color: M.ink, fontWeight: 400 }}>{b.name}</div>
                <div style={{ marginTop: 2, fontSize: 13, color: M.ink2 }}>{b.sub}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24, display:'flex', flexDirection:'column', gap: 14, alignItems:'center' }}>
        <MGlass radius={9999} tint={0.85} style={{ width:'100%', height: 64, display:'flex', alignItems:'center', justifyContent:'center', boxShadow:'0 1px 1px rgba(15,27,45,0.04), 0 12px 30px rgba(74,111,165,0.20), inset 0 1px 0 rgba(255,255,255,0.9)' }}>
          <span style={{ position:'relative', zIndex:1, fontFamily: M.serif, fontSize: 22, color: M.ink, fontWeight: 400 }}>Unlock — €14.99 once</span>
        </MGlass>
        <div style={{ fontSize: 13, color: M.ink3 }}>Restore purchase</div>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// Widgets preview
// ─────────────────────────────────────────────────────────────
function WidgetSmall() {
  return (
    <MGlass radius={22} tint={0.7} style={{ width: 158, height: 158, padding: 16, position:'relative' }}>
      <div style={{ position:'relative', zIndex:1, height:'100%', display:'flex', flexDirection:'column' }}>
        <div style={{ display:'flex', alignItems:'center', gap: 4, fontSize: 10, color: M.ink3, letterSpacing: 2, textTransform:'uppercase' }}>
          {Icons.flame()} Streak
        </div>
        <div className="serif" style={{ fontSize: 76, color: M.ink, lineHeight: 0.9, fontWeight: 200, marginTop: 'auto', letterSpacing: -2 }}>12</div>
        <div style={{ fontSize: 11, color: M.ink2 }}>days</div>
      </div>
    </MGlass>
  );
}

function WidgetMedium() {
  return (
    <MGlass radius={22} tint={0.7} style={{ width: 338, height: 158, padding: 18 }}>
      <div style={{ position:'relative', zIndex:1, height:'100%', display:'flex', alignItems:'stretch', gap: 18 }}>
        <div style={{ flex: 1, borderRight:`0.5px solid ${M.hairline}`, paddingRight: 14, display:'flex', flexDirection:'column' }}>
          <div style={{ fontSize: 9.5, color: M.ink3, letterSpacing: 2, textTransform:'uppercase' }}>Streak</div>
          <div className="serif" style={{ fontSize: 64, color: M.ink, lineHeight: 0.9, fontWeight: 200, marginTop:'auto', letterSpacing: -2 }}>12</div>
          <div style={{ fontSize: 11, color: M.ink2 }}>days · 6 this week</div>
        </div>
        <div style={{ flex: 1.1, display:'flex', flexDirection:'column', justifyContent:'space-between' }}>
          <div>
            <div style={{ fontSize: 9.5, color: M.ink3, letterSpacing: 2, textTransform:'uppercase' }}>Last session</div>
            <div className="serif" style={{ fontSize: 22, color: M.ink, fontWeight: 400, marginTop: 4 }}>20 min</div>
            <div style={{ fontSize: 11, color: M.ink2 }}>Today · Rain</div>
          </div>
          <div>
            <div style={{ fontSize: 9.5, color: M.ink3, letterSpacing: 2, textTransform:'uppercase' }}>This week</div>
            <div className="serif" style={{ fontSize: 22, color: M.ink, fontWeight: 400, marginTop: 4 }}>2.4 hrs</div>
          </div>
        </div>
      </div>
    </MGlass>
  );
}

function WidgetLarge() {
  return (
    <MGlass radius={22} tint={0.7} style={{ width: 338, height: 338, padding: 22 }}>
      <div style={{ position:'relative', zIndex:1, height:'100%', display:'flex', flexDirection:'column' }}>
        <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between' }}>
          <div>
            <div style={{ fontSize: 10, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Streak</div>
            <div className="serif" style={{ fontSize: 60, color: M.ink, lineHeight: 1, fontWeight: 200, marginTop: 4, letterSpacing: -1.5 }}>12 <span style={{ fontSize: 16, color: M.ink2 }}>days</span></div>
          </div>
          <div style={{ textAlign:'right' }}>
            <div style={{ fontSize: 10, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>Week</div>
            <div className="serif" style={{ fontSize: 22, color: M.ink, marginTop: 8, fontWeight: 400 }}>2.4 hrs</div>
          </div>
        </div>
        <div style={{ marginTop: 18, flex: 1, display:'flex', alignItems:'center' }}>
          <Heatmap/>
        </div>
        <div style={{ display:'flex', justifyContent:'space-between', marginTop: 4 }}>
          {[
            { l: 'Today', v: '20m' }, { l: 'Avg', v: '19m' }, { l: 'Total', v: '42h' }, { l: 'Sessions', v: '132' }
          ].map(s => (
            <div key={s.l}>
              <div style={{ fontSize: 9.5, color: M.ink3, letterSpacing: 1.5, textTransform:'uppercase' }}>{s.l}</div>
              <div className="serif" style={{ fontSize: 17, color: M.ink, marginTop: 2 }}>{s.v}</div>
            </div>
          ))}
        </div>
      </div>
    </MGlass>
  );
}

function WidgetLockScreen() {
  return (
    <MGlass radius={14} tint={0.35} blur={20} style={{ padding:'8px 14px', display:'inline-flex', alignItems:'center', gap: 10 }}>
      <div style={{ position:'relative', zIndex:1, display:'flex', alignItems:'center', gap: 10 }}>
        {Icons.flame('#fff')}
        <span style={{ fontFamily: M.serif, fontSize: 19, color:'#fff', fontWeight: 400 }}>12</span>
        <span style={{ fontSize: 12, color:'rgba(255,255,255,0.75)' }}>day streak</span>
      </div>
    </MGlass>
  );
}
