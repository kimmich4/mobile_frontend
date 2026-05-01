from pathlib import Path
import json
import math
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
CHARTS = ROOT / "charts"
CHARTS.mkdir(parents=True, exist_ok=True)


def load_summary():
    with open(ROOT / "results" / "metrics_summary.json", "r", encoding="utf-8") as f:
        return json.load(f)


def save_bar(metric, title, ylabel=None):
    summary = load_summary()
    rows = []
    for mode, values in summary["aggregate"].items():
        rows.append({"mode": mode.replace("_", " "), "value": values.get(metric, 0)})
    df = pd.DataFrame(rows)
    fig, ax = plt.subplots(figsize=(7, 5), dpi=180)
    colors = ["#3B82F6", "#10B981"]
    ax.bar(df["mode"], df["value"], color=colors[: len(df)])
    ax.set_title(title)
    ax.set_ylabel(ylabel or metric)
    ax.grid(axis="y", alpha=0.25)
    for i, value in enumerate(df["value"]):
        ax.text(i, value, f"{value:.3f}" if value <= 1.5 else f"{value:.0f}", ha="center", va="bottom")
    fig.tight_layout()
    fig.savefig(CHARTS / f"{metric}.png")
    plt.close(fig)


def comparison_table():
    summary = load_summary()
    metrics = [
        "precision",
        "recall",
        "f1",
        "instruction_adherence",
        "constraint_compliance",
        "structure_compliance",
        "completeness",
        "faithfulness",
        "latency_ms",
        "token_usage",
        "overall_score",
    ]
    rows = []
    for metric in metrics:
        row = {"metric": metric}
        for mode in ["llm_only", "rag"]:
            row[mode] = summary["aggregate"].get(mode, {}).get(metric, 0)
        rows.append(row)
    df = pd.DataFrame(rows)
    fig, ax = plt.subplots(figsize=(11, 5.5), dpi=180)
    ax.axis("off")
    display = df.copy()
    for col in ["llm_only", "rag"]:
        display[col] = display[col].map(lambda x: f"{x:.3f}" if isinstance(x, (int, float)) and x <= 10 else f"{x:.0f}")
    table = ax.table(cellText=display.values, colLabels=display.columns, loc="center", cellLoc="center")
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 1.35)
    ax.set_title("LLM-only vs LLM + RAG Aggregate Comparison", pad=16)
    fig.tight_layout()
    fig.savefig(CHARTS / "side_by_side_comparison_table.png")
    plt.close(fig)


def per_request_full_comparison_table():
    summary = load_summary()
    rows = []
    metrics = [
        "precision",
        "recall",
        "f1",
        "instruction_adherence",
        "constraint_compliance",
        "structure_compliance",
        "completeness",
        "personalization",
        "faithfulness",
        "latency_ms",
        "token_usage",
        "efficiency_score",
        "overall_score",
    ]
    per_case = summary["perCase"]
    case_ids = sorted({row["caseId"] for row in per_case})
    by_case_mode = {(row["caseId"], row["mode"]): row for row in per_case}

    for case_id in case_ids:
        llm = by_case_mode.get((case_id, "llm_only"), {})
        rag = by_case_mode.get((case_id, "rag"), {})
        for metric in metrics:
            llm_value = llm.get(metric, 0)
            rag_value = rag.get(metric, 0)
            if metric in {"latency_ms", "token_usage"}:
                winner = "LLM-only" if llm_value < rag_value else "RAG"
            else:
                winner = "LLM-only" if llm_value > rag_value else "RAG"
            rows.append(
                {
                    "case": case_id,
                    "field": metric,
                    "LLM-only": llm_value,
                    "LLM+RAG": rag_value,
                    "delta RAG-LLM": rag_value - llm_value,
                    "winner": winner,
                }
            )

    df = pd.DataFrame(rows)
    display = df.copy()
    for col in ["LLM-only", "LLM+RAG", "delta RAG-LLM"]:
        display[col] = display.apply(
            lambda row: f"{row[col]:.0f}" if row["field"] in {"latency_ms", "token_usage"} else f"{row[col]:.3f}",
            axis=1,
        )

    rows_per_image = 34
    for part, start in enumerate(range(0, len(display), rows_per_image), start=1):
        chunk = display.iloc[start : start + rows_per_image]
        fig_height = max(8, 0.34 * len(chunk) + 1.8)
        fig, ax = plt.subplots(figsize=(14, fig_height), dpi=180)
        ax.axis("off")
        table = ax.table(
            cellText=chunk.values,
            colLabels=chunk.columns,
            loc="center",
            cellLoc="center",
        )
        table.auto_set_font_size(False)
        table.set_fontsize(7.5)
        table.scale(1, 1.25)

        winner_col = list(chunk.columns).index("winner")
        for row_idx in range(1, len(chunk) + 1):
            winner = chunk.iloc[row_idx - 1]["winner"]
            color = "#DBEAFE" if winner == "LLM-only" else "#D1FAE5"
            for col_idx in range(len(chunk.columns)):
                table[(row_idx, col_idx)].set_facecolor(color if col_idx == winner_col else "#FFFFFF")

        ax.set_title(
            f"Per-request Full Field Comparison: LLM-only vs LLM + RAG (Part {part})",
            pad=16,
        )
        fig.tight_layout()
        fig.savefig(CHARTS / f"per_request_full_comparison_part_{part}.png")
        plt.close(fig)


def per_request_metric_delta_heatmap():
    summary = load_summary()
    metrics = [
        "precision",
        "recall",
        "f1",
        "instruction_adherence",
        "constraint_compliance",
        "structure_compliance",
        "completeness",
        "personalization",
        "faithfulness",
        "efficiency_score",
        "overall_score",
    ]
    per_case = summary["perCase"]
    case_ids = sorted({row["caseId"] for row in per_case})
    by_case_mode = {(row["caseId"], row["mode"]): row for row in per_case}
    matrix = []
    for case_id in case_ids:
        llm = by_case_mode.get((case_id, "llm_only"), {})
        rag = by_case_mode.get((case_id, "rag"), {})
        matrix.append([rag.get(metric, 0) - llm.get(metric, 0) for metric in metrics])

    df = pd.DataFrame(matrix, index=case_ids, columns=metrics)
    fig, ax = plt.subplots(figsize=(13, 6), dpi=180)
    image = ax.imshow(df.values, cmap="RdYlGn", vmin=-0.25, vmax=0.25, aspect="auto")
    ax.set_xticks(range(len(metrics)))
    ax.set_xticklabels([m.replace("_", "\n") for m in metrics], rotation=0, fontsize=8)
    ax.set_yticks(range(len(case_ids)))
    ax.set_yticklabels(case_ids)
    ax.set_title("Per-request Metric Delta Heatmap (LLM + RAG minus LLM-only)")
    for i in range(len(case_ids)):
        for j in range(len(metrics)):
            ax.text(j, i, f"{df.iloc[i, j]:.2f}", ha="center", va="center", fontsize=7)
    cbar = fig.colorbar(image, ax=ax)
    cbar.set_label("Positive means RAG scored higher")
    fig.tight_layout()
    fig.savefig(CHARTS / "per_request_metric_delta_heatmap.png")
    plt.close(fig)


def grouped_case_bar(metric, title, ylabel=None, lower_is_better=False):
    summary = load_summary()
    per_case = summary["perCase"]
    case_ids = sorted({row["caseId"] for row in per_case})
    by_case_mode = {(row["caseId"], row["mode"]): row for row in per_case}
    llm_values = [by_case_mode.get((case_id, "llm_only"), {}).get(metric, 0) for case_id in case_ids]
    rag_values = [by_case_mode.get((case_id, "rag"), {}).get(metric, 0) for case_id in case_ids]

    x = range(len(case_ids))
    width = 0.38
    fig, ax = plt.subplots(figsize=(10, 5.5), dpi=180)
    ax.bar([i - width / 2 for i in x], llm_values, width, label="LLM-only", color="#3B82F6")
    ax.bar([i + width / 2 for i in x], rag_values, width, label="LLM + RAG", color="#10B981")
    ax.set_title(title)
    ax.set_ylabel(ylabel or metric)
    ax.set_xticks(list(x))
    ax.set_xticklabels(case_ids)
    ax.grid(axis="y", alpha=0.25)
    ax.legend()

    if not lower_is_better and max(llm_values + rag_values) <= 1.05:
        ax.set_ylim(0, 1.08)

    for i, (llm, rag) in enumerate(zip(llm_values, rag_values)):
        label_fmt = "{:.0f}" if metric in {"latency_ms", "token_usage"} else "{:.2f}"
        ax.text(i - width / 2, llm, label_fmt.format(llm), ha="center", va="bottom", fontsize=7, rotation=90)
        ax.text(i + width / 2, rag, label_fmt.format(rag), ha="center", va="bottom", fontsize=7, rotation=90)

    subtitle = "Lower is better" if lower_is_better else "Higher is better"
    ax.text(0.99, 0.98, subtitle, transform=ax.transAxes, ha="right", va="top", fontsize=8)
    fig.tight_layout()
    fig.savefig(CHARTS / f"per_request_{metric}_grouped_bar.png")
    plt.close(fig)


def all_fields_grouped_dashboard():
    summary = load_summary()
    metrics = [
        ("precision", "Precision", False),
        ("recall", "Recall", False),
        ("f1", "F1", False),
        ("instruction_adherence", "Instruction", False),
        ("constraint_compliance", "Constraints", False),
        ("structure_compliance", "Structure", False),
        ("completeness", "Completeness", False),
        ("personalization", "Personalization", False),
        ("faithfulness", "Faithfulness", False),
        ("efficiency_score", "Efficiency", False),
        ("overall_score", "Overall", False),
        ("latency_ms", "Latency ms", True),
        ("token_usage", "Tokens", True),
    ]
    per_case = summary["perCase"]
    case_ids = sorted({row["caseId"] for row in per_case})
    by_case_mode = {(row["caseId"], row["mode"]): row for row in per_case}

    fig, axes = plt.subplots(5, 3, figsize=(18, 20), dpi=180)
    axes = axes.flatten()
    width = 0.38
    x = list(range(len(case_ids)))

    for ax, (metric, title, lower_is_better) in zip(axes, metrics):
        llm_values = [by_case_mode.get((case_id, "llm_only"), {}).get(metric, 0) for case_id in case_ids]
        rag_values = [by_case_mode.get((case_id, "rag"), {}).get(metric, 0) for case_id in case_ids]
        ax.bar([i - width / 2 for i in x], llm_values, width, label="LLM-only", color="#3B82F6")
        ax.bar([i + width / 2 for i in x], rag_values, width, label="LLM + RAG", color="#10B981")
        ax.set_title(f"{title} ({'lower' if lower_is_better else 'higher'} is better)", fontsize=10)
        ax.set_xticks(x)
        ax.set_xticklabels(case_ids, rotation=30, ha="right", fontsize=8)
        ax.grid(axis="y", alpha=0.2)
        if not lower_is_better and max(llm_values + rag_values) <= 1.05:
            ax.set_ylim(0, 1.08)

    for ax in axes[len(metrics):]:
        ax.axis("off")

    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", ncol=2, frameon=False)
    fig.suptitle("All Per-request Comparison Fields: LLM-only vs LLM + RAG", y=0.995, fontsize=16)
    fig.tight_layout(rect=(0, 0, 1, 0.975))
    fig.savefig(CHARTS / "all_fields_per_request_grouped_dashboard.png")
    plt.close(fig)


def radar_chart():
    summary = load_summary()
    metrics = [
        "instruction_adherence",
        "constraint_compliance",
        "structure_compliance",
        "completeness",
        "personalization",
        "faithfulness",
        "f1",
    ]
    labels = [m.replace("_", "\n") for m in metrics]
    angles = [n / float(len(metrics)) * 2 * math.pi for n in range(len(metrics))]
    angles += angles[:1]
    fig = plt.figure(figsize=(7, 7), dpi=180)
    ax = plt.subplot(111, polar=True)
    for mode, color in [("llm_only", "#3B82F6"), ("rag", "#10B981")]:
        values = [summary["aggregate"].get(mode, {}).get(m, 0) for m in metrics]
        values += values[:1]
        ax.plot(angles, values, linewidth=2, label=mode.replace("_", " "), color=color)
        ax.fill(angles, values, alpha=0.15, color=color)
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_ylim(0, 1)
    ax.set_title("Main Quality Dimensions", pad=20)
    ax.legend(loc="upper right", bbox_to_anchor=(1.2, 1.1))
    fig.tight_layout()
    fig.savefig(CHARTS / "quality_radar.png")
    plt.close(fig)


def prompt_comparison_visual():
    llm_prompt = (ROOT / "prompts" / "llm_only_plain_prompt.txt").read_text(encoding="utf-8")
    flow = json.loads((ROOT / "reports" / "backend_flow_reconstruction.json").read_text(encoding="utf-8"))
    rag_text = "\n".join(flow["steps"])
    rows = pd.DataFrame(
        [
            {"dimension": "Message roles", "LLM-only": "single user prompt", "LLM + RAG": "system + user"},
            {"dimension": "Retrieved context", "LLM-only": "none", "LLM + RAG": "Qdrant top 3 chunks"},
            {"dimension": "Prompt style", "LLM-only": "plain human request", "LLM + RAG": "backend task + schema + critical rules"},
            {"dimension": "Approx prompt chars", "LLM-only": len(llm_prompt), "LLM + RAG": len(rag_text)},
        ]
    )
    fig, ax = plt.subplots(figsize=(10, 4.5), dpi=180)
    ax.axis("off")
    table = ax.table(cellText=rows.values, colLabels=rows.columns, cellLoc="center", loc="center")
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 1.5)
    ax.set_title("Prompt Construction Differences", pad=16)
    fig.tight_layout()
    fig.savefig(CHARTS / "prompt_comparison.png")
    plt.close(fig)


def main():
    metrics = [
        ("precision", "Precision", None),
        ("recall", "Recall", None),
        ("f1", "F1 Score", None),
        ("instruction_adherence", "Instruction Adherence", None),
        ("constraint_compliance", "Constraint Compliance", None),
        ("structure_compliance", "Structure Compliance", None),
        ("completeness", "Completeness", None),
        ("faithfulness", "Faithfulness", None),
        ("latency_ms", "Latency", "milliseconds"),
        ("token_usage", "Token Usage", "tokens"),
    ]
    for metric, title, ylabel in metrics:
        save_bar(metric, title, ylabel)
    comparison_table()
    per_request_full_comparison_table()
    per_request_metric_delta_heatmap()
    grouped_specs = [
        ("precision", "Per-request Precision", None, False),
        ("recall", "Per-request Recall", None, False),
        ("f1", "Per-request F1", None, False),
        ("instruction_adherence", "Per-request Instruction Adherence", None, False),
        ("constraint_compliance", "Per-request Constraint Compliance", None, False),
        ("structure_compliance", "Per-request Structure Compliance", None, False),
        ("completeness", "Per-request Completeness", None, False),
        ("personalization", "Per-request Personalization", None, False),
        ("faithfulness", "Per-request Faithfulness", None, False),
        ("efficiency_score", "Per-request Efficiency Score", None, False),
        ("overall_score", "Per-request Overall Score", None, False),
        ("latency_ms", "Per-request Latency", "milliseconds", True),
        ("token_usage", "Per-request Token Usage", "tokens", True),
    ]
    for metric, title, ylabel, lower_is_better in grouped_specs:
        grouped_case_bar(metric, title, ylabel, lower_is_better)
    all_fields_grouped_dashboard()
    radar_chart()
    prompt_comparison_visual()


if __name__ == "__main__":
    main()
