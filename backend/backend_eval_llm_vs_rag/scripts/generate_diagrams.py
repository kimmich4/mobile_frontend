from pathlib import Path
import json
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
CHARTS = ROOT / "charts"
CHARTS.mkdir(parents=True, exist_ok=True)


def backend_pipeline_diagram():
    flow_path = ROOT / "reports" / "backend_flow_reconstruction.json"
    if flow_path.exists():
        flow = json.loads(flow_path.read_text(encoding="utf-8"))
        steps = [
            "Express route",
            "Merge user fields",
            "Calculate BMR/TDEE/calories",
            "Build contextPrefix + task",
            "Validate search query",
            "HF embedding",
            "Qdrant search",
            "Format vector constraints",
            "Inject context",
            "DeepSeek request",
            "Parse JSON response",
        ]
    else:
        steps = ["Express route", "RAG retrieval", "DeepSeek request", "Parse JSON response"]

    fig, ax = plt.subplots(figsize=(14, 4.8), dpi=180)
    ax.axis("off")
    x_positions = [i for i in range(len(steps))]
    for i, (x, label) in enumerate(zip(x_positions, steps)):
        ax.text(
            x,
            0,
            label,
            ha="center",
            va="center",
            bbox=dict(boxstyle="round,pad=0.35", fc="#EFF6FF", ec="#2563EB", lw=1.2),
            fontsize=8,
        )
        if i < len(steps) - 1:
            ax.annotate(
                "",
                xy=(x + 0.68, 0),
                xytext=(x + 0.32, 0),
                arrowprops=dict(arrowstyle="->", color="#374151", lw=1.3),
            )
    ax.set_xlim(-0.7, len(steps) - 0.3)
    ax.set_ylim(-1, 1)
    ax.set_title("Real Backend RAG Pipeline Reconstructed from Code", pad=18)
    fig.tight_layout()
    fig.savefig(CHARTS / "backend_rag_pipeline_flow.png")
    plt.close(fig)


if __name__ == "__main__":
    backend_pipeline_diagram()
