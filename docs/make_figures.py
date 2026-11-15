"""Pipeline animations for the README.     python docs/make_figures.py

A cycle-by-cycle model of our 5-stage pipeline (IF, ID, EX, MEM, WB; branches resolved in ID by the
next-address block, as in rtl/next_addr_bl.vhd). It draws the classic pipeline diagram and the occupancy of each
stage, for:
  1. pipeline.gif : the program preloaded in our instruction memory (rtl/RING_BUFFER.vhd)
  2. hazards.gif  : a read-after-write dependency with no handling, with stalls (bubbles), with forwarding,
                    and the load-use case
  3. branch.gif   : a taken BEQ: the instruction fetched behind it is flushed into a bubble
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch
from PIL import Image

OUT = Path(__file__).resolve().parent / "figures"
OUT.mkdir(parents=True, exist_ok=True)
BG, FG, MUTED, GRID = "#0b1020", "#f3f4f6", "#9ca3af", "#1f2937"
STAGES = ["IF", "ID", "EX", "MEM", "WB"]
COL = {"IF": "#3b82f6", "ID": "#8b5cf6", "EX": "#f59e0b", "MEM": "#10b981", "WB": "#ef4444"}
STAGE_NAME = {"IF": "fetch", "ID": "decode + reg read", "EX": "ALU", "MEM": "data memory", "WB": "write back"}


def I(text, dst=None, srcs=(), kind="alu", taken=False):
    return dict(text=text, dst=dst, srcs=tuple(srcs), kind=kind, taken=taken)


# ====================================================================================== the model
def schedule(prog, policy="none"):
    """Return rows [(label, {cycle: stage}, kind)] where kind is 'instr', 'bubble' or 'flushed'."""
    rows, last = [], None
    produced = {}                                           # reg -> (ex, mem, wb, kind) of its latest writer
    flush_next = False
    branch_redirect = None
    for i, ins in enumerate(prog):
        if last is None:
            if_s = 1
        else:
            if_s = last["id"]
            if branch_redirect is not None:
                if_s = branch_redirect
        id_s = max(if_s + 1, last["ex"] if last else 0)
        ex = max(id_s + 1, (last["ex"] + 1) if last else 0)
        haz = []
        for r in ins["srcs"]:
            if r in produced:
                p = produced[r]
                if policy == "stall":
                    need = p["wb"] + 1                       # write in 1st half of WB, read in 2nd half of ID
                elif policy == "forward":
                    need = (p["mem"] + 1) if p["kind"] == "lw" else (p["ex"] + 1)
                else:
                    need = ex
                if need > ex:
                    ex = need
                haz.append((r, p, need))
        stalls = ex - (id_s + 1)
        for k in range(stalls):                             # bubbles flow down EX -> MEM -> WB
            c = id_s + 1 + k
            rows.append(("bubble", {c: "EX", c + 1: "MEM", c + 2: "WB"}, "bubble", None))
        cells = {c: "IF" for c in range(if_s, id_s)}
        cells.update({c: "ID" for c in range(id_s, ex)})
        cells.update({ex: "EX", ex + 1: "MEM", ex + 2: "WB"})
        info = dict(i=i, ins=ins, if_=if_s, id=id_s, ex=ex, mem=ex + 1, wb=ex + 2, haz=haz, stalls=stalls)
        if flush_next:                                       # fetched behind a taken branch: squashed
            rows.append((ins["text"], {if_s: "IF"}, "flushed", info))
            rows.append(("bubble", {if_s + 1: "ID", if_s + 2: "EX", if_s + 3: "MEM", if_s + 4: "WB"}, "bubble", None))
            flush_next = False
            info = dict(info, id=if_s + 1, ex=if_s + 2)
            last = info
            continue
        rows.append((ins["text"], cells, "instr", info))
        if ins["dst"]:
            produced[ins["dst"]] = dict(ex=ex, mem=ex + 1, wb=ex + 2, kind=ins["kind"])
        branch_redirect = None
        if ins["kind"] == "beq" and ins["taken"]:
            flush_next = True
            branch_redirect = None
        last = info
        if flush_next:
            # the target is fetched the cycle after BEQ leaves ID
            pass
    return rows


def schedule_branch(prog):
    rows = schedule(prog, "none")
    # after a flushed row, the following real instruction (the target) must be fetched at beq.id + 1
    out, shift = [], 0
    for lab, cells, kind, info in rows:
        if kind == "flushed":
            out.append((lab, cells, kind, info))
            continue
        out.append((lab, cells, kind, info))
    return out


# ====================================================================================== drawing
def draw_frame(fig, rows, cycle, ncyc, title, subtitle, notes, arrows=()):
    fig.clf(); fig.set_facecolor(BG)
    fig.text(0.02, 0.945, title, color=FG, fontsize=15, weight="bold")
    fig.text(0.02, 0.905, subtitle, color=MUTED, fontsize=11)
    # --- stage strip
    sx = fig.add_axes([0.2, 0.74, 0.78, 0.13]); sx.set_xlim(0, 5); sx.set_ylim(0, 1); sx.axis("off")
    occ = {}
    for lab, cells, kind, _ in rows:
        st = cells.get(cycle)
        if st:
            occ.setdefault(st, []).append((lab, kind))
    for k, st in enumerate(STAGES):
        sx.add_patch(FancyBboxPatch((k + 0.06, 0.08), 0.88, 0.62, boxstyle="round,pad=0,rounding_size=0.06",
                                    fc=COL[st] + "33", ec=COL[st], lw=2))
        sx.text(k + 0.5, 0.86, f"{st} · {STAGE_NAME[st]}", color=COL[st], ha="center", fontsize=9.5, weight="bold")
        for lab, kind in occ.get(st, [])[:1]:
            if kind == "bubble":
                sx.add_patch(Circle((k + 0.5, 0.39), 0.17, fc="#6b7280", ec="white", lw=1))
                sx.text(k + 0.5, 0.39, "nop", color="white", ha="center", va="center", fontsize=8)
            else:
                sx.text(k + 0.5, 0.39, lab, color=FG if kind == "instr" else "#f87171", ha="center", va="center",
                        fontsize=9.5, family="monospace")
        if k < 4:
            sx.plot([k + 0.97, k + 1.03], [0.39, 0.39], color=MUTED, lw=3)
    fig.text(0.02, 0.8, f"cycle {cycle}", color=FG, fontsize=16, weight="bold", family="monospace")
    # --- pipeline diagram
    ax = fig.add_axes([0.2, 0.06, 0.78 * 0.74, 0.62]); ax.set_facecolor(BG)
    n = max(len(rows), 7)                                   # fixed row height across scenes
    ax.set_xlim(0.5, ncyc + 0.5); ax.set_ylim(n + 0.6, 0.3)
    for c in range(1, ncyc + 1):
        ax.axvline(c - 0.5, color=GRID, lw=0.8)
        ax.text(c, 0.15 + 0, str(c), color=MUTED, ha="center", fontsize=8.5)
    ax.axvspan(cycle - 0.5, cycle + 0.5, color="white", alpha=0.07)
    for r, (lab, cells, kind, info) in enumerate(rows, start=1):
        color = MUTED if kind == "bubble" else ("#f87171" if kind == "flushed" else FG)
        ax.text(0.35, r, lab, color=color, ha="right", va="center", fontsize=9, family="monospace", clip_on=False)
        for c, st in cells.items():
            if c > cycle:
                continue
            if kind == "bubble":
                ax.add_patch(Circle((c, r), 0.32, fc="#4b5563", ec="#9ca3af", lw=0.8))
                ax.text(c, r, "nop", color="white", ha="center", va="center", fontsize=6.5)
                continue
            stall = st == "ID" and info and c > info["id"]
            fc = COL[st] if not stall else COL[st] + "66"
            ax.add_patch(FancyBboxPatch((c - 0.44, r - 0.32), 0.88, 0.64, boxstyle="round,pad=0,rounding_size=0.08",
                                        fc=fc, ec="white" if kind == "flushed" else "none", lw=1,
                                        hatch="///" if stall else None))
            ax.text(c, r, "stall" if stall else st, color="white", ha="center", va="center", fontsize=7.5,
                    weight="bold")
            if kind == "flushed":
                ax.plot([c - 0.44, c + 0.44], [r - 0.32, r + 0.32], color="white", lw=2)
                ax.plot([c - 0.44, c + 0.44], [r + 0.32, r - 0.32], color="white", lw=2)
    for (c0, r0, c1, r1, col, txt, when) in arrows:
        if cycle >= when:
            ax.add_patch(FancyArrowPatch((c0, r0), (c1, r1), arrowstyle="-|>", mutation_scale=14, color=col, lw=2.2,
                                         connectionstyle="arc3,rad=-0.25", zorder=6))
            if txt:
                ax.text((c0 + c1) / 2 + 0.3, (r0 + r1) / 2, txt, color=col, fontsize=8.5, weight="bold", zorder=7)
    ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values():
        s.set_visible(False)
    # --- notes
    y = 0.64
    for txt, col in notes:
        fig.text(0.79, y, txt, color=col, fontsize=10.5, va="top")
        y -= 0.034 * (txt.count("\n") + 1) + 0.035


def grab(fig, frames):
    fig.canvas.draw()
    frames.append(Image.fromarray(np.asarray(fig.canvas.buffer_rgba())[..., :3]).quantize(colors=255))


def animate(scenes, path, size=(13, 7.2)):
    fig = plt.figure(figsize=size, dpi=75, facecolor=BG)
    frames, dur = [], []
    for sc in scenes:
        rows = sc["rows"]
        ncyc = max(max(c for c in cells) for _, cells, _, _ in rows)
        for cyc in range(1, ncyc + 1):
            draw_frame(fig, rows, cyc, sc.get("ncyc", ncyc), sc["title"], sc["subtitle"],
                       sc["notes"](cyc) if callable(sc["notes"]) else sc["notes"], sc.get("arrows", ()))
            grab(fig, frames); dur.append(650)
        dur[-1] = sc.get("hold", 2600)
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=dur, loop=0)
    plt.close(fig)
    print(path.name, len(frames), "frames")


def row_of(rows, text):
    return [k for k, r in enumerate(rows, start=1) if r[0] == text][0]


# ====================================================================================== scenes
def pipeline_gif():
    prog = [I("LW   r6", "r6", (), "lw"), I("SUB  r4,r1,r2", "r4", ("r1", "r2")),
            I("ADDI r5,r1,7", "r5", ("r1",)), I("ADD  r3,r2,r1", "r3", ("r2", "r1")),
            I("SW   r7", None, ("r7",), "sw"), I("ADD  r3,r2,r1", "r3", ("r2", "r1"))]
    rows = schedule(prog)
    done = lambda c: sum(1 for _, cells, k, _ in rows if k == "instr" and max(cells) <= c)
    notes = lambda c: [(f"instructions finished: {done(c)}", FG),
                       ("once the pipeline is full,\none instruction completes\nevery cycle", MUTED),
                       ("this program (from our\ninstruction memory) has no\nback-to-back dependencies,\nso it never stalls", MUTED),
                       ("R-type: 82.5 ns multi-cycle\n→ 29.7 ns pipelined\n= 2.78× throughput", "#fbbf24")]
    animate([dict(rows=rows, title="Our 5-stage pipeline running the preloaded program",
                  subtitle="IF fetch · ID decode + register read (+ branch resolve) · EX ALU · MEM data memory · WB write back",
                  notes=notes, hold=3500)], OUT / "pipeline.gif")


def hazards_gif():
    prog = [I("ADD  r3,r2,r1", "r3", ("r2", "r1")), I("SUB  r4,r3,r1", "r4", ("r3", "r1")),
            I("ADDI r5,r4,7", "r5", ("r4",))]
    scenes = []
    rows = schedule(prog, "none")
    a = row_of(rows, "ADD  r3,r2,r1"); b = row_of(rows, "SUB  r4,r3,r1")
    scenes.append(dict(rows=rows, title="Data hazard · read-after-write",
                       subtitle="SUB needs r3, but ADD only writes r3 back in cycle 5",
                       notes=[("SUB reads r3 in ID\n(cycle 3)", FG), ("ADD writes r3 in WB\n(cycle 5)", FG),
                              ("→ SUB would use the\nOLD value of r3 ✗", "#f87171"),
                              ("ADDI has the same\nproblem with r4", MUTED)],
                       arrows=[(5, a, 3, b, "#f87171", "too late", 3)], ncyc=11))
    rows = schedule(prog, "stall")
    a = row_of(rows, "ADD  r3,r2,r1"); b = row_of(rows, "SUB  r4,r3,r1")
    nb = sum(1 for r in rows if r[2] == "bubble")
    scenes.append(dict(rows=rows, title="Fix 1 · stall: hold the instruction in ID and insert bubbles",
                       subtitle="bubbles (nop) flow down the pipeline until the value has been written back",
                       notes=[(f"{nb} bubbles inserted", "#fbbf24"),
                              ("SUB waits in ID until ADD\nhas written r3 back\n(write in 1st half of the\ncycle, read in the 2nd)", FG),
                              ("correct, but every\ndependency costs 2 cycles", MUTED)], ncyc=11))
    rows = schedule(prog, "forward")
    a = row_of(rows, "ADD  r3,r2,r1"); b = row_of(rows, "SUB  r4,r3,r1"); c = row_of(rows, "ADDI r5,r4,7")
    scenes.append(dict(rows=rows, title="Fix 2 · forwarding (bypassing)",
                       subtitle="the ALU result is fed straight from the EX/MEM pipeline register back into the ALU input",
                       notes=[("0 bubbles", "#34d399"), ("the value exists after EX\n(cycle 3): no need to wait\nfor write-back", FG),
                              ("costs a few multiplexers\nin the ALU input path", MUTED)],
                       arrows=[(3.45, a, 3.6, b, "#34d399", "EX/MEM → EX", 4), (4.45, b, 4.6, c, "#34d399", "", 5)],
                       ncyc=11))
    prog2 = [I("LW   r6", "r6", (), "lw"), I("ADD  r3,r6,r1", "r3", ("r6", "r1"))]
    rows = schedule(prog2, "forward")
    a = row_of(rows, "LW   r6"); b = row_of(rows, "ADD  r3,r6,r1")
    scenes.append(dict(rows=rows, title="Load-use hazard · one bubble even with forwarding",
                       subtitle="a loaded value only exists after MEM, one cycle too late for the next instruction's EX",
                       notes=[("1 bubble, then\nMEM/WB → EX forward", "#fbbf24"),
                              ("compilers hide it by placing\nan independent instruction\nin between", MUTED)],
                       arrows=[(4.45, a, 4.6, b + 0, "#34d399", "MEM/WB → EX", 5)], ncyc=11))
    animate(scenes, OUT / "hazards.gif")


def branch_gif():
    prog = [I("ADD  r3,r2,r1", "r3", ("r2", "r1")), I("BEQ  r1,r7,+4", None, ("r1", "r7"), "beq", taken=True),
            I("SW   r7", None, ("r7",), "sw"), I("ADD  r3,r2,r1  ← target", "r3", ("r2", "r1"))]
    rows = schedule(prog, "forward")
    animate([dict(rows=rows, title="Control hazard · a taken BEQ",
                  subtitle="our next-address block resolves the branch in ID (stage 2), so only ONE wrong instruction is ever fetched",
                  notes=[("cycle 3: BEQ in ID compares\nr1 and r7 → equal, taken", FG),
                         ("SW was fetched in the same\ncycle: it is flushed and\nbecomes a bubble", "#f87171"),
                         ("cycle 4: the target\nis fetched", FG),
                         ("resolving in EX instead\nwould waste 2 cycles per\ntaken branch", MUTED)],
                  ncyc=9, hold=3500)], OUT / "branch.gif")


def banner():
    fig = plt.figure(figsize=(16, 4), dpi=100, facecolor=BG)
    t = fig.add_axes([0, 0, 0.42, 1]); t.axis("off")
    t.text(0.07, 0.6, "5-stage pipelined CPU", color="white", fontsize=32, weight="bold", transform=t.transAxes)
    t.text(0.07, 0.43, "16-bit ISA · VHDL · Intel MAX 10 FPGA", color="#e5e7eb", fontsize=15, transform=t.transAxes)
    t.text(0.07, 0.29, "LW · SW · ADD · SUB · ADDI · BEQ · JRI   ·   2.78× throughput vs multi-cycle",
           color=MUTED, fontsize=12, transform=t.transAxes)
    ax = fig.add_axes([0.45, 0.1, 0.53, 0.8]); ax.set_facecolor(BG); ax.axis("off")
    for r in range(5):
        for k, st in enumerate(STAGES):
            c = r + k + 1
            ax.add_patch(FancyBboxPatch((c - 0.44, r - 0.33), 0.88, 0.66, boxstyle="round,pad=0,rounding_size=0.08",
                                        fc=COL[st], ec="none", alpha=0.95))
            ax.text(c, r, st, color="white", ha="center", va="center", fontsize=10, weight="bold")
    ax.set_xlim(0.3, 10.7); ax.set_ylim(4.6, -0.6)
    fig.savefig(OUT / "banner.png", facecolor=BG); plt.close(fig)


if __name__ == "__main__":
    banner()
    pipeline_gif()
    hazards_gif()
    branch_gif()
    for f in sorted(OUT.iterdir()):
        print(f"{f.name:26s} {f.stat().st_size / 1e6:6.2f} MB")
