/**
 * LiveSheet REGEN: Sovereign Engine (v1.1.0)
 * ---------------------------------------------------------
 * Author: dummyowner (Guest-1Play)
 * Description: Single-file full interpreter for .lsl language.
 * No-shredding, Full-logic integration.
 */

class LiveSheetREGEN {
    constructor() {
        this.entities = new Map();
        this.dataCache = new Map();
        this.isReady = false;
        this.init();
    }

    async init() {
        console.log("%c[LSL Core] Initializing Sovereign System...", "color: #00ff00; font-weight: bold;");

        // 1. .lsl 파일 탐색 (CSS 방식의 꺼내 쓰기)
        const lslLink = document.querySelector('link[rel="livesheet"]');
        if (!lslLink) {
            console.error("[LSL Error] No livesheet link found. <link rel='livesheet' href='main.lsl'>");
            return;
        }

        try {
            const rawLSL = await this.fetchSource(lslLink.href);
            const parsedData = this.parseLSL(rawLSL);
            await this.bootstrap(parsedData);
        } catch (err) {
            console.error("[LSL Critical] Bootstrapping failed:", err);
        }
    }

    async fetchSource(url) {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Source not found: ${url}`);
        return await response.text();
    }

    parseLSL(text) {
        const result = { kernel: {}, chronos: {}, themes: {}, streams: {}, entities: {} };
        const cleanText = text.replace(/--.*$/gm, ''); // 주석 제거

        // 정규식을 통한 섹션별 파싱
        const sections = cleanText.split(/@(\w+)\s*#?([\w\d_]+)?\s*{/);
        
        for (let i = 1; i < sections.length; i += 3) {
            const type = sections[i].trim();
            const id = sections[i+1] ? sections[i+1].trim() : 'default';
            const body = sections[i+2].split('}')[0].trim();
            const pairs = body.split(';').filter(p => p.includes(':')).reduce((acc, p) => {
                const [k, v] = p.split(':').map(s => s.trim());
                acc[k] = v.replace(/['"]/g, '');
                return acc;
            }, {});

            if (type === 'kernel') result.kernel = pairs;
            else if (type === 'chronos') result.chronos = pairs;
            else if (type === 'aesthetic' || type === 'theme') result.themes[id] = pairs;
            else if (type === 'inject' || type === 'data_stream') result.streams[id] = pairs;
            else if (type === 'entity' || type === 'object') result.entities[id] = pairs;
        }
        return result;
    }

    async bootstrap(data) {
        this.config = data;
        this.setupContainer();

        // 엔티티 생성 및 개별 생명 주기(Pulse) 할당
        for (const [id, spec] of Object.entries(data.entities)) {
            const entityEl = this.createEntityElement(id, spec);
            this.entities.set(id, {
                el: entityEl,
                spec: spec,
                timer: null,
                isPaused: false
            });
            this.triggerPulse(id);
        }
        this.isReady = true;
    }

    setupContainer() {
        // 4:3 뷰포트 솔버
        const container = document.createElement('div');
        container.id = 'lsl-viewport';
        Object.assign(container.style, {
            position: 'relative',
            width: '800px',
            height: '600px',
            aspectRatio: '4 / 3',
            margin: '0 auto',
            backgroundColor: '#f0f0f0',
            overflow: 'hidden',
            border: '2px solid #000'
        });
        document.body.appendChild(container);
        this.viewport = container;
    }

    createEntityElement(id, spec) {
        const el = document.createElement('div');
        el.id = `lsl-${id}`;
        el.className = 'lsl-entity';
        
        // Aesthetic/Theme 적용
        const theme = this.config.themes[spec.apply.replace('#', '')] || {};
        Object.assign(el.style, {
            position: 'absolute',
            border: theme.stroke || '2px solid #000',
            borderRadius: '4px',
            padding: '10px',
            backgroundColor: '#fff',
            transition: 'all 0.5s ease-in-out',
            boxShadow: '4px 4px 0px #000'
        });

        // 레이아웃 처리 (Grid 기반)
        if (spec.layout) {
            const coords = spec.layout.match(/\d+/g);
            if (coords) {
                el.style.left = `${coords[0]}%`;
                el.style.top = `${coords[1]}%`;
                el.style.width = `${coords[2]}%`;
                el.style.height = `${coords[3]}%`;
            }
        }

        // 호버 인지 (Pointer Watcher)
        el.addEventListener('mouseenter', () => this.setEntityPause(id, true));
        el.addEventListener('mouseleave', () => this.setEntityPause(id, false));

        this.viewport.appendChild(el);
        return el;
    }

    setEntityPause(id, state) {
        const entity = this.entities.get(id);
        if (entity) {
            entity.isPaused = state;
            entity.el.style.transform = state ? 'scale(1.02)' : 'scale(1)';
            entity.el.style.borderColor = state ? '#ff0000' : (this.config.themes[entity.spec.apply.replace('#', '')]?.stroke.split(' ')[2] || '#000');
            if (state) console.log(`[LSL Chronos] Entity #${id} paused by user.`);
        }
    }

    async triggerPulse(id) {
        const entity = this.entities.get(id);
        if (!entity) return;

        const pulseLogic = async () => {
            if (!entity.isPaused) {
                const streamId = entity.spec.bind.match(/\d+/)[0];
                const stream = this.config.streams[streamId];
                
                if (stream) {
                    try {
                        const rawData = await this.fetchSource(stream.source);
                        
                        // Ghost Buffer: 델타 체크
                        if (this.dataCache.get(id) === rawData) {
                            console.log(`[LSL Delta] #${id} : No change detected. Skipping render.`);
                        } else {
                            this.dataCache.set(id, rawData);
                            this.renderEntity(entity, rawData);
                        }
                    } catch (e) {
                        this.handleError(entity);
                    }
                }
            }

            // 30~60초 랜덤 박동 주입
            const nextPulse = Math.floor(Math.random() * (60000 - 30000 + 1)) + 30000;
            entity.timer = setTimeout(pulseLogic, nextPulse);
        };

        pulseLogic();
    }

    renderEntity(entity, data) {
        // 데이터 업데이트 시 Flip 효과
        entity.el.style.transform = 'rotateY(90deg)';
        setTimeout(() => {
            entity.el.innerHTML = `<pre style="font-size:12px; overflow:hidden;">${data}</pre>`;
            entity.el.style.transform = 'rotateY(0deg)';
        }, 250);
    }

    handleError(entity) {
        entity.el.innerHTML = `<div class="lsl-noise" style="background:repeating-linear-gradient(0deg, #ccc, #ccc 1px, #fff 1px, #fff 2px); width:100%; height:100%;">[SIGNAL LOST]</div>`;
    }
}

// 엔진 자동 실행
window.addEventListener('DOMContentLoaded', () => {
    window.LSL_ENGINE = new LiveSheetREGEN();
});    font: "lsl-tech-dot";           -- LSL 전용 도트 매트릭스 가독성 확보
}

-- ==========================================
-- 4. RESILIENCE (환경 적응 및 복구 시스템)
-- ==========================================
@resilience {
    -- 서버 다운 시 '죽은 화면' 대신 시스템 고유의 페르소나 유지
    on_data_loss: "render_noise_and_wait"; 
    reconnect_strategy: exponential_backoff(120s);
    emergency_buffer: "display_last_cached"; -- 최악의 경우 마지막 데이터를 유지
}

-- ==========================================
-- 5. DATA INJECTION (데이터 스트림 및 JS 유닛 결합)
-- ==========================================
-- LSL 언어 내에서 실행되는 독립 로직 유닛들
@inject stream(1) {
    source: "https://api.ems-service.com/v1/latest";
    logic_unit: "units/ems_processor.js"; -- LSL 전용 데이터 가공 유닛
}

@inject stream(2) {
    source: "https://status.livesheet.org/ping";
    logic_unit: "units/sys_health.js";
}

-- ==========================================
-- 6. ENTITY DEFINITION (독립 개체 선언)
-- ==========================================
-- #notice_board는 이제 단순한 타일이 아닌 LSL의 독립 개체(Entity)입니다.
@entity #notice_board {
    bind: stream(1);
    apply: #regen_v1;
    
    -- 타일의 본질적 행동 정의
    behavior: {
        entry_anim: "flip-in";
        update_anim: "flip-out";
        hover_focus: true;
    }

    -- 4:3 그리드 시스템 기반 좌표 (솔버가 자동 계산)
    layout: {
        pos: grid(5, 5);
        span: grid(20, 15);
    }
}

@entity #status_monitor {
    bind: stream(2);
    apply: #regen_v1;
    
    -- 이 개체는 시스템 규격보다 더 빠른 독자적 박동을 가짐
    pulse_override: 10s, 20s; 
    
    layout: {
        pos: grid(30, 5);
        span: grid(10, 10);
    }
    display_type: "slide-status";
}
