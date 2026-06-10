// =====================================================
// 공통 파라미터 — 풀리 내장형 벨트 감속 관절 모듈
// 좌표 규약:
//  - 베이스 플레이트 윗면 = z 0 (베이스는 z -base_t .. 0)
//  - 출력축(스트리퍼 볼트) 중심 = (0, 0)
//  - 모터축 중심 = (-axis_dist, 0)
//  - 암은 +x 방향(모터 반대쪽)으로 뻗는다
// =====================================================

axis_dist = 99.2;     // 축간거리 C
base_t    = 8;        // 베이스 플레이트 두께

// ---- 베이스 플레이트 외형 ----
// 패싯(각면) 윤곽: 모터 패드(45° 챔퍼) + 테이퍼 웨이스트 + 출력 패싯/스웹트 윙
// 꼭짓점 좌표는 motor_side.scad의 _base_pts 참조
mount_hole_d = 4.5;                        // 프레임 장착 M4 관통홀
mount_holes  = [[-123, 0], [-41, 0], [20, 28], [20, -28]];

// ---- 출력축 적층 (z는 베이스 윗면 기준) ----
// 스트리퍼 볼트는 머리 하향: 머리+와셔가 베이스 아래, M6 너트가 적층 위
brg_od = 22; brg_id = 8; brg_w = 7;     // 608ZZ
skate_od = 10; skate_l = 10;            // 스케이트 베어링 스페이서 8x10x10
standoff_h   = 2 * skate_l;             // 스탠드오프 스페이서 2개 z 0..20
lower_brg_z0 = standoff_h;              // 하부 베어링 z 20..27
spacer_h     = skate_l;                 // 내륜 스페이서 z 27..37
upper_brg_z0 = lower_brg_z0 + brg_w + spacer_h;  // 상부 베어링 z 37..44
stack_top    = upper_brg_z0 + brg_w;    // 내륜 적층 상단 z 44
shim_t       = 0.7;                     // 심 와셔 합 (0.5+0.2) z 44..44.7
top_washer_t = 1.6;                     // 상부 M8 평와셔 z 44.7..46.3
washer_od    = 16;                      // M8 평와셔 외경 (외륜 Ø17.8 미접촉)

// ---- 스트리퍼 볼트 Ø8 쇼울더 L55 x M6 (나사부 10mm) ----
head_washer_t = 1.6;                    // 머리측 M8 평와셔 (필수)
shoulder_l    = 55;
shoulder_z0   = -base_t - head_washer_t;     // -9.6
shoulder_z1   = shoulder_z0 + shoulder_l;    // 45.4
m6_thread_l   = 10;                     // 표준 쇼울더볼트 나사 길이
bolt_head_d   = 13;  bolt_head_h = 5.5;
nut_m6_af     = 10;  nut_m6_h = 6;      // M6 나일록 (DIN985)
axle_hole_d   = 8.3;                    // 베이스 축 구멍 (Ø8 쇼울더 통과)

// ---- 출력 풀리 GT2 60T (12mm bore, 보스 하향, 무가공) ----
p60_pd   = 60 * 2 / PI;                 // 약 38.2
p60_od   = 37.7;                        // 이빨 외경 (PD - 0.5)
p60_flange_d = 44;  p60_flange_t = 1.0;
p60_boss_d   = 32;  p60_boss_h   = 6.5; // 세트스크류 보스 (아래로)
p60_bore = 12;                          // 스페이서(OD10) 통과 클리어런스
p60_z0   = 1.5;                         // 보스 하단 (베이스와 1.5 간극)
p60_fl1_z0   = p60_z0 + p60_boss_h;          // 하부 플랜지 z 8..9
p60_teeth_z0 = p60_fl1_z0 + p60_flange_t;    // 이빨부 z 9..16.2
p60_teeth_h  = 7.2;
p60_z1   = p60_teeth_z0 + p60_teeth_h + p60_flange_t;  // 풀리 상단 z 17.2

// ---- 클램프 링 / 허브 체결 ----
clamp_ring_od = 56;  clamp_ring_id = 35;     // 내경은 보스 Ø32 회피
clamp_ring_z0 = 5;   clamp_ring_z1 = p60_fl1_z0;  // z 5..8
clamp_pcd     = 50;                     // M3 볼트 PCD (플랜지 Ø44 바깥)
clamp_bolt_angles = [60, 180, 300];     // 암(+x) 및 암 폭 회피 → 공구 접근

// ---- 암 허브 / 암 ----
hub_od        = 32;
hub_z0        = p60_z1 - 1;             // 16.2 (풀리 받이 포켓 깊이 1)
hub_z1        = 45;
hub_flange_od = 58;  hub_flange_t = 4;
hub_flange_z1 = hub_z0 + hub_flange_t;  // 20.2
hub_recess_d  = 44.6; hub_recess_h = 1.0;  // 풀리 상부 플랜지 센터링 포켓
hub_flange_core_d = 48;                    // 3-로브 플랜지 중심 디스크 (리세스 + 벽 1.7)
flange_lobe_d = 13;                        // 볼트 자리 로브
arm_len       = 85;
arm_w         = 32;                        // 허브측 폭 (= hub_od)
arm_w_tip     = 18;                        // 끝단 폭 (테이퍼)
arm_z0        = 39;  arm_z1 = 45;
arm_slots = [[20, 36, 12], [42, 56, 10], [62, 74, 7]];  // 경량화 트러스 컷 [x0,x1,폭]

// ---- 벨트 GT2-280, 6mm 폭 ----
belt_w  = 6;
belt_t  = 1.5;
belt_z0 = 9.4;                          // z 9.4..15.4
p20_pd  = 20 * 2 / PI;                  // 약 12.7

// ---- NEMA 17 + 20T 풀리 (보스 하향) ----
nema_side   = 42.3;
nema_len    = 40;                       // 몸체 z -48..-8 (베이스 아래 매달림)
nema_hole_pitch = 31;                   // M3 4개, 정사각
nema_boss_d = 22;   nema_boss_h = 2;
nema_shaft_d = 5;
nema_shaft_top = 14;                    // 축 길이 22mm 기준 (베이스 윗면 기준)
p20_od   = 12.2;                        // 이빨 외경 근사
p20_flange_d = 18;
p20_boss_d = 16;  p20_boss_h = 6.5;
p20_z0   = 0.9;                              // 보스 하단
p20_fl1_z0   = p20_z0 + p20_boss_h;          // 하부 플랜지 z 7.4..8.4
p20_teeth_z0 = p20_fl1_z0 + 1;               // 이빨부 z 8.4..16
p20_teeth_h  = 7.6;
p20_z1   = p20_teeth_z0 + p20_teeth_h + 1;   // 풀리 상단 z 17

// ---- 모터 슬롯 / 잭 스크류 ----
slot_w = 3.4;  slot_l = 14;             // 장축 x 방향, 조절 범위 ±5.3mm
boss_slot_w = 22.5; boss_slot_l = 34.5;
jack_block_x = -axis_dist + 32;         // 모터 앞쪽(출력 풀리 쪽) 블록 중심 x
jack_block = [10, 14, 14];              // 블록 크기 (베이스 하면 아래 — 모터 몸체와 같은 높이)
jack_z = -base_t - jack_block[2] / 2;   // 스크류 축 높이 z -15

// ---- 색상 ----
c_print  = [0.30, 0.55, 0.85];          // 프린팅 부품 (파랑 계열)
c_print2 = [0.40, 0.70, 0.95];
c_steel  = [0.75, 0.76, 0.78];
c_alu    = [0.85, 0.86, 0.88];
c_belt   = [0.15, 0.15, 0.15];
c_motor  = [0.25, 0.25, 0.28];

$fa = 4; $fs = 0.4;
