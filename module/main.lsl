-- [[ LiveSheet REGEN: Master Module Specification (v1.0.0) ]]
-- Author: dummyowner (Guest-1Play)
-- Description: 이 파일은 LiveSheet 엔진을 구동하는 순수 선언형 마스터 시트입니다.
-- 엔진은 이 시트를 읽고 4:3 뷰포트 내에서 숨겨진 생명 주기(Heartbeat)를 시작합니다.

-- ==========================================
-- 1. SYSTEM CONTROL (시스템 코어 설정)
-- ==========================================
@system {
    viewport: 4:3;                 -- 해상도 비율 강제 (레트로 감성 유지)
    engine_mode: "no-stop";        -- 브라우저/앱이 켜져 있는 한 절대 멈추지 않음
    core_logic: "lsl_core.js";     -- LSL 문법을 해석하고 JS 샌드박스를 관리할 핵심 엔진
    layout_solver: "grid-snap";    -- [추가] 4:3 화면 밖으로 나가는 오브젝트를 자동 보정
}

-- ==========================================
-- 2. LIFE CYCLE (생명 주기 & 최적화)
-- ==========================================
@global_cycle {
    interval_range: 30s, 60s;      -- 모든 오브젝트의 기본 랜덤 심장박동 주기
    hover_action: "freeze";        -- 포인터 와쳐: 마우스 오버 시 해당 타일의 타이머 즉시 정지
    ghost_buffer: true;            -- [추가] 데이터 델타 체크: 새로 가져온 데이터가 이전과 같으면 애니메이션 생략 (리소스 절약)
}

-- ==========================================
-- 3. VISUAL THEME (디자인 프리셋)
-- ==========================================
@theme #regen_standard {
    outline: "3px solid black";    -- Messy Outline: 두껍고 거친 손그림 느낌
    border_radius: "2px 10px 3px 8px"; -- 불규칙한 모서리로 수작업 느낌 극대화
    palette: "muted_flat";         -- 눈이 편안한 저채도 플랫 컬러 시스템
    font_family: "technical_dot";  -- 시스템 기본 폰트
}

-- ==========================================
-- 4. FALLBACK & ERROR (생존 시스템)
-- ==========================================
@fallback {
    -- [추가] 서버 점검 등으로 데이터 연결이 끊겼을 때 엔진이 죽지 않도록 방어
    on_timeout: "show_static_noise"; -- 레트로 TV 노이즈 화면 송출
    retry_interval: 120s;          -- 에러 발생 시 2분마다 재연결 시도
}

-- ==========================================
-- 5. DATA STREAM (외부 정보 연결 & JS 파서 결합)
-- ==========================================
-- LSL이 데이터를 가져오면, processor에 지정된 JS가 데이터를 가공함
@data_stream id(1) {
    url: "https://api.ems-service.com/v1/latest";
    method: "GET";
    processor: "modules/ems_parser.js";  -- [JS 샌드박스] 원본 데이터를 LSL 텍스트로 변환
}

@data_stream id(2) {
    url: "https://status.livesheet.org/ping";
    method: "GET";
    processor: "modules/sys_parser.js";  -- [JS 샌드박스] 서버 상태를 색상 코드로 변환
}

-- ==========================================
-- 6. OBJECT DEFINITION (실제 구동되는 라이브 타일)
-- ==========================================
@object #notice_board {
    -- 1번 스트림 데이터를 가져옴
    use_stream: id(1);
    apply_theme: #regen_standard;
    
    -- [JS 샌드박스] LSL 타이머가 허락할 때만 화면을 그리는 렌더링 로직
    use_logic: "modules/board_render.js"; 

    display: "flip-tile";          -- 30~60초 뒤 데이터 갱신 시 뒤집기 애니메이션
    position: 10%, 10%;            -- 레이아웃 솔버가 4:3에 맞춰 자동 배치
    size: 300px, 150px;
}

@object #status_monitor {
    use_stream: id(2);
    apply_theme: #regen_standard;
    
    -- 이 타일만 특별히 시스템 기본값을 무시하고 10~20초 주기로 빠르게 갱신
    refresh_override: 10s, 20s;  
    display: "slide-tile";
    position: 50%, 10%;
    size: 150px, 150px;
}
