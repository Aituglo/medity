// Screens 5-8: Session, Complete, Sound Library, Bells

// ─────────────────────────────────────────────────────────────
// 05 — Session in progress
// ─────────────────────────────────────────────────────────────
function ScreenSession() {
  return (
    <MPhone mood="day">
      <div style={{ position:'absolute', inset: 0, display:'flex', alignItems:'center', justifyContent:'center' }}>
        <MAura size={520} intensity={0.9} style={{}}/>
      </div>

      {/* upward particles (mist) */}
      <svg width="100%" height="100%" style={{ position:'absolute', inset: 0, opacity: 0.55 }}>
        {Array.from({length: 22}).map((_, i) => {
          const x = (i * 53) % 380 + 10;
          const y = 200 + (i * 89) % 500;
          const r = 0.8 + (i % 3) * 0.5;
          return <circle key={i} cx={x} cy={y} r={r} fill={M.accent} opacity={0.18 + (i % 4)*0.05}/>;
        })}
      </svg>

      {/* End — top */}
      <div style={{ position:'absolute', top: 64, left: 0, right: 0, display:'flex', justifyContent:'center', zIndex: 10 }}>
        <div style={{ fontSize: 13, color: M.ink3, letterSpacing: 4, textTransform:'uppercase' }}>End</div>
      </div>

      {/* Center: countdown */}
      <div style={{ position:'absolute', inset: 0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
        <div style={{ position:'relative', width: 320, height: 320, display:'flex', alignItems:'center', justifyContent:'center' }}>
          {/* Faint progress ring */}
          <svg width="320" height="320" viewBox="0 0 320 320" style={{ position:'absolute' }}>
            <circle cx="160" cy="160" r="148" stroke="rgba(15,27,45,0.05)" strokeWidth="1" fill="none"/>
            <circle cx="160" cy="160" r="148"
              stroke={M.accent} strokeOpacity="0.5" strokeWidth="1.2" fill="none"
              strokeDasharray={`${0.32 * 2 * Math.PI * 148} ${2 * Math.PI * 148}`}
              strokeLinecap="round" transform="rotate(-90 160 160)"/>
          </svg>
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center' }}>
            <div className="serif" style={{ fontSize: 96, color: M.ink, lineHeight: 1, fontWeight: 200, letterSpacing: -2, fontVariantNumeric:'tabular-nums' }}>13:42</div>
            <div style={{ marginTop: 14, fontSize: 11, color: M.ink3, letterSpacing: 4, textTransform:'uppercase' }}>Rain · Light</div>
          </div>
        </div>
      </div>

      {/* Pause — bottom */}
      <div style={{ position:'absolute', bottom: 88, left: 0, right: 0, display:'flex', justifyContent:'center' }}>
        <MGlass radius={9999} tint={0.55} style={{ width: 56, height: 56, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <div style={{ position:'relative', zIndex: 1 }}>{Icons.pause()}</div>
        </MGlass>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// 06 — Session complete
// ─────────────────────────────────────────────────────────────
function ScreenComplete() {
  return (
    <MPhone mood="day">
      <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', paddingTop: 168 }}>
        <MAura size={280} style={{ top: 80, left:'50%', transform:'translateX(-50%)' }}/>
        <div className="serif" style={{ fontSize: 52, color: M.ink, letterSpacing: -0.5, fontWeight: 300 }}>Well done.</div>
        <div style={{ marginTop: 14, fontFamily: M.serif, fontSize: 17, color: M.ink2, fontStyle:'italic' }}>Day 12 · streak unbroken</div>

        <MGlass radius={28} tint={0.6} style={{ marginTop: 56, width: 280, padding: 26 }}>
          <div style={{ position:'relative', zIndex:1, display:'grid', gridTemplateColumns:'1fr 1fr', gap: 24 }}>
            <SummaryStat label="Duration" value="20" unit="min"/>
            <SummaryStat label="Sound" value="Rain" unit="Light"/>
            <SummaryStat label="Started" value="6:42" unit="am"/>
            <SummaryStat label="Heart rate" value="62" unit="avg bpm"/>
          </div>
        </MGlass>
      </div>

      <div style={{ position:'absolute', bottom: 36, left: 24, right: 24, display:'flex', flexDirection:'column', gap: 10 }}>
        <MPrimaryButton icon="arrow">Done</MPrimaryButton>
        <div style={{ textAlign:'center', padding: 14, color: M.accent, fontSize: 15, fontWeight: 500 }}>New session</div>
      </div>
    </MPhone>
  );
}

function SummaryStat({ label, value, unit }) {
  return (
    <div>
      <div style={{ fontSize: 10.5, color: M.ink3, letterSpacing: 2.5, textTransform:'uppercase' }}>{label}</div>
      <div style={{ marginTop: 6, display:'flex', alignItems:'baseline', gap: 6 }}>
        <div className="serif" style={{ fontSize: 28, color: M.ink, fontWeight: 300, lineHeight: 1 }}>{value}</div>
        <div style={{ fontSize: 12, color: M.ink2 }}>{unit}</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 07 — Sound library (modal sheet)
// ─────────────────────────────────────────────────────────────
function MiniWave({ active }) {
  return (
    <svg width="32" height="14" viewBox="0 0 32 14">
      {Array.from({length: 14}).map((_, i) => {
        const h = 2 + Math.abs(Math.sin(i * 0.9)) * 10 + (i % 3);
        return <rect key={i} x={i*2.3} y={(14 - h)/2} width="1.4" height={h} rx="0.7" fill={active ? M.accent : M.ink3}/>
      })}
    </svg>
  );
}

function SoundRow({ name, active, locked, last }) {
  return (
    <div style={{
      display:'flex', alignItems:'center', gap: 14, padding:'14px 20px',
      borderBottom: last ? 'none' : `0.5px solid ${M.hairline}`,
    }}>
      <MiniWave active={active}/>
      <div className="serif" style={{ flex: 1, fontSize: 17, color: active ? M.ink : M.ink, fontWeight: 400 }}>{name}</div>
      {active && Icons.check()}
      {locked && Icons.lock()}
    </div>
  );
}

function SoundSection({ title, children }) {
  return (
    <div style={{ marginTop: 18 }}>
      <div style={{ fontSize: 10.5, color: M.ink3, letterSpacing: 3, textTransform:'uppercase', padding:'0 22px 8px' }}>{title}</div>
      <MGlass radius={22} tint={0.55} style={{ margin:'0 14px' }}>
        <div style={{ position:'relative', zIndex:1 }}>{children}</div>
      </MGlass>
    </div>
  );
}

function ScreenSounds() {
  return (
    <MPhone mood="dawn">
      {/* Dimmed home behind sheet */}
      <div style={{ position:'absolute', inset: 0, opacity: 0.4, pointerEvents:'none' }}>
        <div style={{ position:'absolute', inset: 0, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <MAura size={360} intensity={0.5}/>
        </div>
      </div>

      {/* Sheet */}
      <div style={{ position:'absolute', left: 0, right: 0, bottom: 0, top: 110,
        background:'linear-gradient(180deg, rgba(244,246,249,0.92), rgba(244,246,249,0.96))',
        backdropFilter:'blur(40px)', WebkitBackdropFilter:'blur(40px)',
        borderTopLeftRadius: 38, borderTopRightRadius: 38,
        boxShadow:'0 -1px 0 rgba(255,255,255,0.6), 0 -16px 40px rgba(15,27,45,0.10)',
        overflow:'hidden',
      }}>
        {/* grabber */}
        <div style={{ display:'flex', justifyContent:'center', padding:'10px 0' }}>
          <div style={{ width: 36, height: 5, borderRadius: 3, background:'rgba(15,27,45,0.18)' }}/>
        </div>
        <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', padding:'8px 22px 4px' }}>
          <div className="serif" style={{ fontSize: 30, color: M.ink, fontWeight: 400 }}>Sound</div>
          <div style={{ fontSize: 14, color: M.accent, fontWeight: 500 }}>Done</div>
        </div>
        <div style={{ overflowY:'auto', height: 'calc(100% - 68px)', paddingBottom: 60 }}>
          <SoundSection title="Nature">
            <SoundRow name="Rain · Light" active/>
            <SoundRow name="Rain · Heavy"/>
            <SoundRow name="Ocean Waves"/>
            <SoundRow name="Ocean Shore"/>
            <SoundRow name="Forest"/>
            <SoundRow name="River"/>
            <SoundRow name="Fire" locked/>
            <SoundRow name="Wind" locked last/>
          </SoundSection>
          <SoundSection title="Noise">
            <SoundRow name="Brown"/>
            <SoundRow name="Pink"/>
            <SoundRow name="White" last/>
          </SoundSection>
          <SoundSection title="Sacred">
            <SoundRow name="Tibetan Bowls" locked/>
            <SoundRow name="Om Chant" locked/>
            <SoundRow name="Temple Ambience" locked last/>
          </SoundSection>
          <SoundSection title="Stillness">
            <SoundRow name="Silence" last/>
          </SoundSection>

          {/* Plus upsell */}
          <MGlass radius={22} tint={0.85} style={{ margin:'22px 14px 22px' }}>
            <div style={{ position:'relative', zIndex:1, padding: 18, display:'flex', alignItems:'center', gap: 14 }}>
              <div style={{ width: 44, height: 44, borderRadius: 14, background:'linear-gradient(180deg,#dde6f3,#b6c8de)', display:'flex', alignItems:'center', justifyContent:'center' }}>
                <div style={{ width: 18, height: 18, borderRadius:'50%', border:'1px solid '+M.ink, boxSizing:'border-box' }}/>
              </div>
              <div style={{ flex: 1 }}>
                <div className="serif" style={{ fontSize: 18, color: M.ink, fontWeight: 400 }}>Medity Plus</div>
                <div style={{ marginTop: 2, fontSize: 13, color: M.ink2 }}>Unlock all sounds, bells, themes.</div>
              </div>
              {Icons.chevron(M.ink2)}
            </div>
          </MGlass>
        </div>
      </div>
    </MPhone>
  );
}

// ─────────────────────────────────────────────────────────────
// 08 — Bells picker
// ─────────────────────────────────────────────────────────────
function BellRow({ name, sub, active, last }) {
  return (
    <div style={{ display:'flex', alignItems:'center', gap: 14, padding:'14px 20px',
      borderBottom: last ? 'none' : `0.5px solid ${M.hairline}` }}>
      <div style={{ width: 32, height: 32, borderRadius:'50%', background:'rgba(74,111,165,0.10)', display:'flex', alignItems:'center', justifyContent:'center' }}>
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M5 6l4-2v6l-4-2z" fill={M.accent}/>
          <path d="M9 4v6" stroke={M.accent} strokeWidth="1.4" strokeLinecap="round"/>
        </svg>
      </div>
      <div style={{ flex: 1 }}>
        <div className="serif" style={{ fontSize: 17, color: M.ink, fontWeight: 400 }}>{name}</div>
        <div style={{ fontSize: 12.5, color: M.ink2 }}>{sub}</div>
      </div>
      {active && Icons.check()}
    </div>
  );
}

function Segmented({ options, active }) {
  return (
    <MGlass radius={9999} tint={0.45} style={{ display:'flex', padding: 4, gap: 2 }}>
      {options.map(o => (
        <div key={o} style={{
          flex: 1, textAlign:'center', padding:'8px 0', borderRadius: 9999,
          fontSize: 13, fontWeight: 500,
          color: o === active ? M.ink : M.ink2,
          background: o === active ? '#fff' : 'transparent',
          boxShadow: o === active ? '0 1px 4px rgba(15,27,45,0.08)' : 'none',
          position:'relative', zIndex:1,
        }}>{o}</div>
      ))}
    </MGlass>
  );
}

function ScreenBells() {
  return (
    <MPhone mood="dawn">
      <div style={{ position:'absolute', inset: 0, opacity: 0.4 }}>
        <div style={{ position:'absolute', inset: 0, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <MAura size={360} intensity={0.5}/>
        </div>
      </div>

      <div style={{ position:'absolute', left: 0, right: 0, bottom: 0, top: 110,
        background:'linear-gradient(180deg, rgba(244,246,249,0.92), rgba(244,246,249,0.96))',
        backdropFilter:'blur(40px)', WebkitBackdropFilter:'blur(40px)',
        borderTopLeftRadius: 38, borderTopRightRadius: 38,
        boxShadow:'0 -1px 0 rgba(255,255,255,0.6), 0 -16px 40px rgba(15,27,45,0.10)',
      }}>
        <div style={{ display:'flex', justifyContent:'center', padding:'10px 0' }}>
          <div style={{ width: 36, height: 5, borderRadius: 3, background:'rgba(15,27,45,0.18)' }}/>
        </div>
        <div style={{ display:'flex', alignItems:'baseline', justifyContent:'space-between', padding:'8px 22px 4px' }}>
          <div className="serif" style={{ fontSize: 30, color: M.ink, fontWeight: 400 }}>Bells</div>
          <div style={{ fontSize: 14, color: M.accent, fontWeight: 500 }}>Done</div>
        </div>

        <SoundSection title="Bell sound">
          <BellRow name="Tibetan bowl" sub="Resonant, warm" active/>
          <BellRow name="Japanese bell" sub="Bright, clean"/>
          <BellRow name="Gong" sub="Deep, lingering"/>
          <BellRow name="Soft chime" sub="Quiet, near"/>
          <BellRow name="Deep bell" sub="Long decay"/>
          <BellRow name="Wood block" sub="Dry, percussive" last/>
        </SoundSection>

        <SoundSection title="Interval bells">
          <div style={{ padding:'18px 20px' }}>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', paddingBottom: 14, borderBottom:`0.5px solid ${M.hairline}` }}>
              <div className="serif" style={{ fontSize: 17, color: M.ink }}>Ring during session</div>
              {/* iOS-style toggle */}
              <div style={{ width: 51, height: 31, borderRadius: 100, background: M.accent, position:'relative' }}>
                <div style={{ position:'absolute', top: 2, right: 2, width: 27, height: 27, borderRadius:'50%', background:'#fff', boxShadow:'0 2px 4px rgba(0,0,0,0.15)' }}/>
              </div>
            </div>
            <div style={{ paddingTop: 16 }}>
              <Segmented options={['Off','5 min','10 min','15 min']} active="10 min"/>
            </div>
          </div>
        </SoundSection>

        <div style={{ padding:'24px 22px 0', fontSize: 12.5, color: M.ink2, lineHeight: 1.5 }}>
          A soft bell will ring at the start, every 10 minutes, and at the end. It plays beneath the sound at low volume.
        </div>
      </div>
    </MPhone>
  );
}

Object.assign(window, {
  ScreenSession, ScreenComplete, ScreenSounds, ScreenBells,
  SummaryStat, MiniWave, SoundRow, SoundSection, BellRow, Segmented,
});
