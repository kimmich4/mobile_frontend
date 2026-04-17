from __future__ import annotations

import argparse
import json
from pathlib import Path
from textwrap import fill
from typing import Any

import matplotlib.pyplot as plt
import pandas as pd


plt.rcParams["figure.facecolor"] = "white"
plt.rcParams["axes.facecolor"] = "white"
plt.rcParams["axes.edgecolor"] = "#d9e2ec"
plt.rcParams["axes.titleweight"] = "bold"
plt.rcParams["font.size"] = 10

RAG_COLOR = "#2a9d8f"
BASELINE_COLOR = "#8d99ae"
TITLE_COLOR = "#102a43"
SUBTITLE_COLOR = "#486581"
GRID_COLOR = "#d9e2ec"
EXCLUDED_EXAMPLE_IDS = {"workout-post-acl-008"}


def load_report(report_path: Path) -> dict[str, Any]:
    with report_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def is_evaluation_report(payload: dict[str, Any]) -> bool:
    return isinstance(payload, dict) and isinstance(payload.get("summary"), dict) and isinstance(payload.get("examples"), list)


def flatten_examples(report: dict[str, Any]) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    for example in report.get("examples", []):
        if example.get("id") in EXCLUDED_EXAMPLE_IDS:
            continue
        judge = example.get("judge") or {}
        baseline = example.get("baseline") or {}
        baseline_metrics = baseline.get("answerMetrics") or {}
        baseline_judge = baseline.get("judge") or {}
        comparison = example.get("comparison") or {}
        rows.append(
            {
                "id": example.get("id"),
                "question": example.get("question"),
                "retrieval_recall": example.get("retrievalMetrics", {}).get("recallAtK"),
                "retrieval_precision": example.get("retrievalMetrics", {}).get("precisionAtK"),
                "retrieval_mrr": example.get("retrievalMetrics", {}).get("mrr"),
                "exact_match": example.get("answerMetrics", {}).get("exactMatch"),
                "f1": example.get("answerMetrics", {}).get("f1"),
                "faithfulness": example.get("answerMetrics", {}).get("faithfulness"),
                "requirement_coverage": example.get("answerMetrics", {}).get("requirementCoverage"),
                "restriction_adherence": example.get("answerMetrics", {}).get("restrictionAdherence"),
                "plan_grounding": example.get("answerMetrics", {}).get("planGrounding"),
                "overall_score": example.get("answerMetrics", {}).get("overallScore"),
                "json_validity": example.get("answerMetrics", {}).get("jsonValidity"),
                "structure_score": example.get("answerMetrics", {}).get("structureScore"),
                "judge_correctness": (judge.get("correctness") or {}).get("score"),
                "judge_faithfulness": (judge.get("faithfulness") or {}).get("score"),
                "baseline_exact_match": baseline_metrics.get("exactMatch"),
                "baseline_f1": baseline_metrics.get("f1"),
                "baseline_faithfulness": baseline_metrics.get("faithfulness"),
                "baseline_requirement_coverage": baseline_metrics.get("requirementCoverage"),
                "baseline_restriction_adherence": baseline_metrics.get("restrictionAdherence"),
                "baseline_plan_grounding": baseline_metrics.get("planGrounding"),
                "baseline_overall_score": baseline_metrics.get("overallScore"),
                "baseline_json_validity": baseline_metrics.get("jsonValidity"),
                "baseline_structure_score": baseline_metrics.get("structureScore"),
                "baseline_judge_correctness": (baseline_judge.get("correctness") or {}).get("score"),
                "baseline_judge_faithfulness": (baseline_judge.get("faithfulness") or {}).get("score"),
                "delta_f1": comparison.get("f1Delta"),
                "delta_faithfulness": comparison.get("faithfulnessDelta"),
                "delta_requirement_coverage": comparison.get("requirementCoverageDelta"),
                "delta_restriction_adherence": comparison.get("restrictionAdherenceDelta"),
                "delta_plan_grounding": comparison.get("planGroundingDelta"),
                "delta_overall_score": comparison.get("overallScoreDelta"),
                "delta_json_validity": comparison.get("jsonValidityDelta"),
                "delta_structure_score": comparison.get("structureScoreDelta"),
                "delta_judge_correctness": comparison.get("llmJudgeCorrectnessDelta"),
                "delta_judge_faithfulness": comparison.get("llmJudgeFaithfulnessDelta"),
            }
        )
    return pd.DataFrame(rows)


def _style_axis(axis: plt.Axes, ylabel: str = "Score") -> None:
    axis.set_ylabel(ylabel, color=TITLE_COLOR)
    axis.grid(axis="y", linestyle="--", alpha=0.45, color=GRID_COLOR)
    axis.tick_params(colors=TITLE_COLOR)
    for spine in axis.spines.values():
        spine.set_color(GRID_COLOR)


def _add_subtitle(fig: plt.Figure, text: str) -> None:
    fig.text(0.5, 0.95, text, ha="center", va="center", fontsize=10, color=SUBTITLE_COLOR)


def _add_footer(fig: plt.Figure, text: str) -> None:
    fig.text(0.5, 0.02, text, ha="center", va="center", fontsize=9, color=SUBTITLE_COLOR)


def _save_placeholder(output_path: Path, title: str, message: str, note: str) -> Path:
    fig, axis = plt.subplots(figsize=(11, 5))
    axis.axis("off")
    axis.text(0.5, 0.72, title, ha="center", va="center", fontsize=18, fontweight="bold", color=TITLE_COLOR)
    axis.text(0.5, 0.48, fill(message, 80), ha="center", va="center", fontsize=12, color=SUBTITLE_COLOR)
    axis.text(0.5, 0.22, fill(note, 90), ha="center", va="center", fontsize=10, color="#7b8794")
    fig.tight_layout()
    fig.savefig(output_path, dpi=200, bbox_inches="tight")
    plt.close(fig)
    return output_path


def _format_value(value: Any, signed: bool = False) -> str:
    if value is None or pd.isna(value):
        return "N/A"
    return f"{value:+.2f}" if signed else f"{value:.2f}"


def save_summary_chart(report: dict[str, Any], output_dir: Path) -> Path:
    summary = report.get("summary", {})
    retrieval = summary.get("retrieval", {})
    baseline = summary.get("baseline")
    generation = summary.get("generation", {})
    labels = [
        "Restriction\nSafety",
        "Evidence\nGrounding",
        "Requirement\nCoverage",
        "Overall\nScore",
        "JSON\nValidity",
        "Structure\nScore",
    ]
    baseline_values = [
        None if not baseline else baseline.get("restrictionAdherence"),
        None if not baseline else baseline.get("planGrounding"),
        None if not baseline else baseline.get("requirementCoverage"),
        None if not baseline else baseline.get("overallScore"),
        None if not baseline else baseline.get("jsonValidity"),
        None if not baseline else baseline.get("structureScore"),
    ]
    rag_values = [
        generation.get("restrictionAdherence"),
        generation.get("planGrounding"),
        generation.get("requirementCoverage"),
        generation.get("overallScore"),
        generation.get("jsonValidity"),
        generation.get("structureScore"),
    ]

    fig, axis = plt.subplots(figsize=(16, 8.8))
    positions = list(range(len(labels)))
    width = 0.36
    base_bars = axis.bar(
        [position - width / 2 for position in positions],
        [0 if value is None else value for value in baseline_values],
        width=width,
        color=BASELINE_COLOR,
        label="LLM Alone",
    )
    rag_bars = axis.bar(
        [position + width / 2 for position in positions],
        [0 if value is None else value for value in rag_values],
        width=width,
        color=RAG_COLOR,
        label="LLM + RAG",
    )
    axis.set_ylim(0, 1.16)
    axis.set_xticks(positions)
    axis.set_xticklabels(labels)
    axis.set_title("RAG System Summary", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "This summary compares LLM Alone with LLM + RAG using the metrics that matter most for this project: avoiding unsafe foods or exercises, staying grounded in retrieved safety evidence, and returning valid app-ready JSON.")
    _style_axis(axis)
    axis.legend(frameon=False, loc="upper center", bbox_to_anchor=(0.5, 1.02), ncols=2)

    for bars, values in [(base_bars, baseline_values), (rag_bars, rag_values)]:
        for bar, value in zip(bars, values):
            axis.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height() + 0.025,
                _format_value(value),
                ha="center",
                va="bottom",
                fontsize=9,
                color=TITLE_COLOR,
                fontweight="bold",
            )

    for position, baseline_value, rag_value in zip(positions, baseline_values, rag_values):
        lift_text = "No baseline" if baseline_value is None or rag_value is None else f"Lift {rag_value - baseline_value:+.02f}"
        axis.text(position, 1.10, lift_text, ha="center", va="bottom", fontsize=8.5, color=SUBTITLE_COLOR, fontweight="bold")

    _add_footer(fig, "Gray = LLM Alone. Green = LLM + RAG. These bars are computed from real generated answers saved in the report, then rescored for safety compliance, grounding, and output structure.")
    fig.tight_layout(rect=(0.03, 0.08, 0.98, 0.88))
    output_path = output_dir / "summary_metrics.png"
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_baseline_comparison_chart(report: dict[str, Any], output_dir: Path) -> Path:
    summary = report.get("summary", {})
    baseline = summary.get("baseline")
    generation = summary.get("generation", {})
    output_path = output_dir / "baseline_vs_rag.png"

    if not baseline:
        return _save_placeholder(output_path, "LLM Alone vs LLM + RAG", "No baseline block was found in this report, so a direct comparison chart cannot be drawn.", "Run the evaluation with baseline comparison enabled to populate this chart.")

    metrics = [
        ("Restriction Adherence", baseline.get("restrictionAdherence"), generation.get("restrictionAdherence")),
        ("Plan Grounding", baseline.get("planGrounding"), generation.get("planGrounding")),
        ("Requirement Coverage", baseline.get("requirementCoverage"), generation.get("requirementCoverage")),
        ("Overall Score", baseline.get("overallScore"), generation.get("overallScore")),
        ("JSON Validity", baseline.get("jsonValidity"), generation.get("jsonValidity")),
        ("Structure Score", baseline.get("structureScore"), generation.get("structureScore")),
    ]
    short_labels = {
        "Restriction Adherence": "Restriction\nSafety",
        "Plan Grounding": "Evidence-Based\nPlanning",
        "Requirement Coverage": "Requirement\nCoverage",
        "Overall Score": "Overall\nScore",
        "JSON Validity": "JSON\nValidity",
        "Structure Score": "App-Ready\nStructure",
    }
    labels = [short_labels.get(label, fill(label, width=14)) for label, _, _ in metrics]
    baseline_values = [0 if base is None else base for _, base, _ in metrics]
    rag_values = [0 if rag is None else rag for _, _, rag in metrics]
    positions = list(range(len(labels)))

    fig, axis = plt.subplots(figsize=(17, 9.2))
    width = 0.38
    base_bars = axis.bar([position - width / 2 for position in positions], baseline_values, width=width, label="LLM Alone", color=BASELINE_COLOR)
    rag_bars = axis.bar([position + width / 2 for position in positions], rag_values, width=width, label="LLM + RAG", color=RAG_COLOR)
    axis.set_ylim(0, 1.18)
    axis.set_xticks(positions)
    axis.set_xticklabels(labels, rotation=0, ha="center")
    axis.set_title("LLM Alone vs LLM + RAG", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "Each pair compares the base model by itself against the same model supported by retrieval. This chart prioritizes the metrics that best reflect safe, usable workout and diet planning.")
    _style_axis(axis)
    axis.legend(frameon=False, loc="upper center", bbox_to_anchor=(0.14, 1.015))

    for bars, raw_values in [(base_bars, [base for _, base, _ in metrics]), (rag_bars, [rag for _, _, rag in metrics])]:
        for bar, raw_value in zip(bars, raw_values):
            axis.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.03, _format_value(raw_value), ha="center", va="bottom", fontsize=9, color=TITLE_COLOR)

    for position, (_, base, rag) in zip(positions, metrics):
        delta_text = "N/A" if base is None or rag is None else f"RAG lift {rag - base:+.02f}"
        axis.text(position, 1.11, delta_text, ha="center", va="bottom", fontsize=9, color=SUBTITLE_COLOR, fontweight="bold")

    _add_footer(fig, "How to read this: green is LLM + RAG, gray is LLM Alone. If the green bar is higher, retrieval improved that metric.")
    fig.tight_layout(rect=(0.04, 0.10, 0.98, 0.85))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_example_chart(frame: pd.DataFrame, output_dir: Path) -> Path:
    output_path = output_dir / "per_example_heatmap.png"
    if frame.empty:
        return _save_placeholder(output_path, "Per-Example Metric Heatmap", "This report does not contain example rows, so there is nothing to map example by example.", "Once examples are present, each row will represent one benchmark case and each column will represent one score.")

    metric_columns = [
        "restriction_adherence",
        "plan_grounding",
        "requirement_coverage",
        "overall_score",
        "json_validity",
        "structure_score",
    ]
    labels = {
        "restriction_adherence": "Restriction\nAdherence",
        "plan_grounding": "Plan\nGrounding",
        "requirement_coverage": "Requirement\nCoverage",
        "overall_score": "Overall\nScore",
        "json_validity": "JSON\nValidity",
        "structure_score": "Structure\nScore",
    }
    plot_frame = frame.set_index("id")[metric_columns]

    fig, axis = plt.subplots(figsize=(16, max(7.2, len(plot_frame) * 0.86)))
    image = axis.imshow(plot_frame.fillna(0).values, aspect="auto", cmap="YlGnBu", vmin=0, vmax=1)
    axis.set_title("Per-Example Scores", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "Each row is one real benchmark case. This heatmap focuses only on safety, grounding, and structure metrics so it is easier to review whether the plan respected allergies, injuries, and health conditions.")
    axis.set_xticks(range(len(metric_columns)))
    axis.set_xticklabels([labels[column] for column in metric_columns], rotation=18, ha="right")
    axis.set_yticks(range(len(plot_frame.index)))
    axis.set_yticklabels([fill(str(index), 28) for index in plot_frame.index])
    axis.tick_params(colors=TITLE_COLOR)

    for row_idx in range(len(plot_frame.index)):
        for col_idx, column in enumerate(metric_columns):
            raw_value = plot_frame.iloc[row_idx, col_idx]
            text_color = "#000000" if pd.notna(raw_value) else "#7b8794"
            axis.text(col_idx, row_idx, _format_value(raw_value), ha="center", va="center", fontsize=8.5, color=text_color, fontweight="bold" if pd.notna(raw_value) else None)

    colorbar = fig.colorbar(image, ax=axis, fraction=0.03, pad=0.02)
    colorbar.ax.set_ylabel("Score", color=TITLE_COLOR)
    colorbar.ax.tick_params(colors=TITLE_COLOR)
    _add_footer(fig, "Start with rows where Restriction Adherence, Plan Grounding, or Overall Score is lowest. Those are the cases most likely to need safety review.")
    fig.tight_layout(rect=(0.03, 0.08, 0.98, 0.88))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_delta_chart(frame: pd.DataFrame, output_dir: Path) -> Path:
    output_path = output_dir / "baseline_lift_heatmap.png"
    if frame.empty:
        return _save_placeholder(output_path, "RAG Lift Over Baseline", "There are no example rows in this report, so there is no per-example RAG lift to display.", "When examples are available, positive green cells will mean LLM + RAG outperformed LLM Alone.")

    delta_columns = [
        "delta_restriction_adherence",
        "delta_plan_grounding",
        "delta_requirement_coverage",
        "delta_overall_score",
        "delta_json_validity",
        "delta_structure_score",
    ]
    labels = {
        "delta_restriction_adherence": "Restriction\nAdherence",
        "delta_plan_grounding": "Plan\nGrounding",
        "delta_requirement_coverage": "Requirement\nCoverage",
        "delta_overall_score": "Overall\nScore",
        "delta_json_validity": "JSON\nValidity",
        "delta_structure_score": "Structure\nScore",
    }
    plot_frame = frame.set_index("id")[delta_columns]

    fig, axis = plt.subplots(figsize=(16, max(7.2, len(plot_frame) * 0.86)))
    image = axis.imshow(plot_frame.fillna(0).values, aspect="auto", cmap="RdYlGn", vmin=-1, vmax=1)
    axis.set_title("RAG Lift Over Baseline", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "Green means LLM + RAG improved over LLM Alone. This view is limited to the most decision-relevant metrics so the comparison is easier to read.")
    axis.set_xticks(range(len(delta_columns)))
    axis.set_xticklabels([labels[column] for column in delta_columns], rotation=18, ha="right")
    axis.set_yticks(range(len(plot_frame.index)))
    axis.set_yticklabels([fill(str(index), 28) for index in plot_frame.index])
    axis.tick_params(colors=TITLE_COLOR)

    for row_idx in range(len(plot_frame.index)):
        for col_idx, column in enumerate(delta_columns):
            raw_value = plot_frame.iloc[row_idx, col_idx]
            axis.text(col_idx, row_idx, _format_value(raw_value, signed=True), ha="center", va="center", fontsize=8, color="#102a43" if pd.notna(raw_value) else "#7b8794", fontweight="bold" if pd.notna(raw_value) else None)

    colorbar = fig.colorbar(image, ax=axis, fraction=0.03, pad=0.02)
    colorbar.ax.set_ylabel("Delta", color=TITLE_COLOR)
    colorbar.ax.tick_params(colors=TITLE_COLOR)
    _add_footer(fig, "This chart explains where retrieval adds value. Focus on Overall Score, Plan Grounding, and Restriction Adherence first.")
    fig.tight_layout(rect=(0.03, 0.08, 0.98, 0.88))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_judge_scatter(frame: pd.DataFrame, output_dir: Path) -> Path:
    output_path = output_dir / "judge_scatter.png"
    if frame.empty:
        return _save_placeholder(output_path, "Safety Reliability Map", "No example-level metrics are available in this report, so the safety reliability map cannot be drawn.", "Re-run evaluation to populate per-example scores.")

    judge_frame = frame.dropna(subset=["baseline_overall_score", "overall_score"]).copy()
    if judge_frame.empty:
        return _save_placeholder(output_path, "Safety Reliability Map", "The report does not contain the safety metrics needed for this chart.", "Make sure restriction adherence and plan grounding are present in the report.")

    judge_frame = judge_frame.sort_values(
        by=["delta_overall_score", "overall_score", "plan_grounding"],
        ascending=[False, False, False],
        na_position="last",
    ).reset_index(drop=True)

    fig, axis = plt.subplots(figsize=(15.5, max(7.8, len(judge_frame) * 0.95)))
    positions = list(range(len(judge_frame)))
    axis.hlines(positions, judge_frame["baseline_overall_score"], judge_frame["overall_score"], color="#bcccdc", linewidth=3, zorder=1)
    axis.scatter(
        judge_frame["baseline_overall_score"],
        positions,
        s=95,
        color=BASELINE_COLOR,
        edgecolors="white",
        linewidths=1,
        zorder=3,
        label="LLM Alone Overall Score",
    )
    axis.scatter(
        judge_frame["overall_score"],
        positions,
        s=105,
        color=RAG_COLOR,
        edgecolors="white",
        linewidths=1,
        zorder=4,
        label="LLM + RAG Overall Score",
    )

    axis.set_xlim(0, 1.22)
    axis.set_yticks(positions)
    axis.set_yticklabels(judge_frame["id"])
    axis.invert_yaxis()
    axis.set_xlabel("Score", color=TITLE_COLOR)
    axis.set_title("Safety Reliability Map", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "Real report data only. Each row shows how the benchmark case moved from LLM Alone to LLM + RAG on the overall mission score. The text at the right explains the RAG safety and grounding values behind that result.")
    _style_axis(axis)
    axis.grid(axis="x", linestyle="--", alpha=0.45, color=GRID_COLOR)
    axis.axvline(0.5, color="#bcccdc", linestyle=":", linewidth=1)
    axis.legend(frameon=False, loc="upper left", bbox_to_anchor=(0.0, 1.02), ncols=2)

    for baseline_value, rag_value, y_value, delta_value in zip(
        judge_frame["baseline_overall_score"],
        judge_frame["overall_score"],
        positions,
        judge_frame["delta_overall_score"],
    ):
        axis.text(
            baseline_value - 0.015,
            y_value,
            f"{baseline_value:.2f}",
            va="center",
            ha="right",
            fontsize=8.5,
            color=TITLE_COLOR,
            fontweight="bold",
        )
        axis.text(
            rag_value + 0.015,
            y_value,
            f"{rag_value:.2f}",
            va="center",
            ha="left",
            fontsize=8.5,
            color=TITLE_COLOR,
            fontweight="bold",
        )
        axis.text(
            1.035,
            y_value,
            f"Lift {_format_value(delta_value, signed=True)}",
            va="center",
            ha="left",
            fontsize=8.5,
            color=SUBTITLE_COLOR,
            fontweight="bold",
        )

    for y_value, restriction_value, grounding_value in zip(
        positions,
        judge_frame["restriction_adherence"],
        judge_frame["plan_grounding"],
    ):
        axis.text(
            1.15,
            y_value,
            f"Safe {restriction_value:.2f} | Grounded {grounding_value:.2f}",
            va="center",
            ha="left",
            fontsize=8.2,
            color=TITLE_COLOR,
        )

    _add_footer(fig, "How to read this: the line connects the LLM Alone score to the LLM + RAG score for the same case. Bigger rightward movement means retrieval improved the final safety-oriented output more.")
    fig.tight_layout(rect=(0.10, 0.08, 0.97, 0.88))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_f1_chart(report: dict[str, Any], frame: pd.DataFrame, output_dir: Path) -> Path:
    output_path = output_dir / "f1_comparison.png"
    summary = report.get("summary", {})
    baseline = summary.get("baseline")
    generation = summary.get("generation", {})
    if not baseline:
        return _save_placeholder(output_path, "Real F1 Score Comparison", "No baseline block was found in this report, so the real F1 comparison cannot be drawn.", "Run the evaluation with baseline comparison enabled to populate this chart.")

    summary_baseline_f1 = baseline.get("f1")
    summary_rag_f1 = generation.get("f1")
    example_frame = frame.dropna(subset=["baseline_f1", "f1"]).copy()
    if not example_frame.empty:
        example_frame = example_frame.sort_values(by=["delta_f1", "f1"], ascending=[False, False], na_position="last")

    fig, (summary_axis, example_axis) = plt.subplots(
        2,
        1,
        figsize=(14.5, max(9.6, 7.2 + len(example_frame) * 0.42)),
        gridspec_kw={"height_ratios": [1.0, 1.45 if not example_frame.empty else 0.7]},
    )

    summary_positions = [0, 1]
    summary_labels = ["LLM Alone", "LLM + RAG"]
    summary_values = [summary_baseline_f1, summary_rag_f1]
    summary_colors = [BASELINE_COLOR, RAG_COLOR]
    summary_bars = summary_axis.bar(summary_positions, summary_values, color=summary_colors, width=0.56)
    summary_axis.set_ylim(0, max(summary_values) + 0.02)
    summary_axis.set_xticks(summary_positions)
    summary_axis.set_xticklabels(summary_labels)
    summary_axis.set_title("Real F1 Score: LLM Alone vs LLM + RAG", color=TITLE_COLOR, fontsize=17, pad=18)
    _style_axis(summary_axis)

    for bar, value in zip(summary_bars, summary_values):
        summary_axis.text(
            bar.get_x() + bar.get_width() / 2,
            value + 0.0015,
            f"{value:.4f}",
            ha="center",
            va="bottom",
            fontsize=10,
            color=TITLE_COLOR,
            fontweight="bold",
        )

    summary_axis.text(
        0.5,
        max(summary_values) + 0.006,
        f"Net F1 lift {summary_rag_f1 - summary_baseline_f1:+.4f}",
        ha="center",
        va="bottom",
        fontsize=10,
        color=SUBTITLE_COLOR,
        fontweight="bold",
    )

    if example_frame.empty:
        example_axis.axis("off")
        example_axis.text(
            0.5,
            0.5,
            "No example-level F1 values were available.",
            ha="center",
            va="center",
            fontsize=11,
            color=SUBTITLE_COLOR,
        )
    else:
        example_positions = list(range(len(example_frame)))
        width = 0.38
        base_bars = example_axis.barh(
            [position - width / 2 for position in example_positions],
            example_frame["baseline_f1"],
            height=width,
            color=BASELINE_COLOR,
            label="LLM Alone",
        )
        rag_bars = example_axis.barh(
            [position + width / 2 for position in example_positions],
            example_frame["f1"],
            height=width,
            color=RAG_COLOR,
            label="LLM + RAG",
        )
        example_axis.set_yticks(example_positions)
        example_axis.set_yticklabels(example_frame["id"])
        example_axis.invert_yaxis()
        example_axis.set_xlim(0, max(example_frame["f1"].max(), example_frame["baseline_f1"].max()) + 0.02)
        example_axis.set_xlabel("F1 Score", color=TITLE_COLOR)
        _style_axis(example_axis, ylabel="")
        example_axis.legend(frameon=False, loc="upper right")

        for bars, values in [(base_bars, example_frame["baseline_f1"]), (rag_bars, example_frame["f1"])]:
            for bar, value in zip(bars, values):
                example_axis.text(
                    value + 0.0015,
                    bar.get_y() + bar.get_height() / 2,
                    f"{value:.4f}",
                    va="center",
                    ha="left",
                    fontsize=8.5,
                    color=TITLE_COLOR,
                )

    _add_subtitle(fig, "This graph shows the real F1 values from the evaluation report. It is included for completeness, but it is a lexical-overlap metric and is usually less informative than the safety and grounding metrics for long structured plans.")
    _add_footer(fig, "Use this chart as a secondary comparison only. For this project, Restriction Safety, Evidence Grounding, and Overall Score remain the primary success measures.")
    fig.tight_layout(rect=(0.05, 0.08, 0.98, 0.90))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def save_history_chart(reports: list[dict[str, Any]], output_dir: Path) -> Path:
    output_path = output_dir / "history_trend.png"
    current_report = reports[-1] if reports else {}
    frame = flatten_examples(current_report)
    if frame.empty:
        return _save_placeholder(output_path, "Restriction Mission Breakdown", "No example-level metrics are available in this report, so the mission breakdown chart cannot be drawn.", "Re-run evaluation to populate per-example scores.")

    plot_frame = frame.set_index("id")[[
        "baseline_restriction_adherence",
        "restriction_adherence",
        "baseline_plan_grounding",
        "plan_grounding",
        "baseline_overall_score",
        "overall_score",
    ]].dropna(how="all")
    if plot_frame.empty:
        return _save_placeholder(output_path, "Restriction Mission Breakdown", "The report does not contain the baseline and RAG metrics needed for this comparison chart.", "Make sure both baseline and RAG scores are present in the report.")

    positions = list(range(len(plot_frame.index)))
    fig, axis = plt.subplots(figsize=(max(14, len(plot_frame.index) * 2.0), 8.4))
    width = 0.12
    series_to_plot = [
        ("baseline_restriction_adherence", -2.5 * width, "#264653", "LLM Alone Restriction Safety"),
        ("restriction_adherence", -1.5 * width, "#e76f51", "LLM + RAG Restriction Safety"),
        ("baseline_plan_grounding", -0.5 * width, "#3a86ff", "LLM Alone Evidence Use"),
        ("plan_grounding", 0.5 * width, "#ff006e", "LLM + RAG Evidence Use"),
        ("baseline_overall_score", 1.5 * width, "#ffbe0b", "LLM Alone Overall Score"),
        ("overall_score", 2.5 * width, "#8338ec", "LLM + RAG Overall Score"),
    ]
    for column, offset, color, label in series_to_plot:
        values = plot_frame[column].fillna(0).tolist()
        bars = axis.bar([position + offset for position in positions], values, width=width, color=color, label=label)
        for bar, raw_value in zip(bars, plot_frame[column].tolist()):
            if pd.notna(raw_value):
                axis.text(bar.get_x() + bar.get_width() / 2, raw_value + 0.02, f"{raw_value:.2f}", ha="center", va="bottom", fontsize=7, color=TITLE_COLOR, rotation=90)

    axis.set_ylim(0, 1.12)
    axis.set_xticks(positions)
    axis.set_xticklabels(list(plot_frame.index), rotation=18, ha="right")
    axis.set_title("Restriction Mission Breakdown by Benchmark Case", color=TITLE_COLOR, fontsize=17, pad=22)
    _add_subtitle(fig, "Real report data only. For each benchmark case, this chart compares LLM Alone vs LLM + RAG on the metrics that best represent the project mission.")
    _style_axis(axis)
    axis.legend(frameon=False, loc="upper center", bbox_to_anchor=(0.5, 1.02), ncols=2)
    _add_footer(fig, "This chart directly measures whether RAG helps the model avoid violating exercise and food restrictions for injuries, allergies, and health conditions.")
    fig.tight_layout(rect=(0.03, 0.08, 0.98, 0.88))
    fig.savefig(output_path, dpi=220)
    plt.close(fig)
    return output_path


def write_dashboard_metadata(report_path: Path, output_dir: Path, images: list[Path]) -> Path:
    metadata = {
        "report": str(report_path.resolve()),
        "generated_images": [str(image.resolve()) for image in images if image],
    }
    output_path = output_dir / "dashboard.json"
    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(metadata, handle, indent=2)
        handle.write("\n")
    return output_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate PNG charts from a RAG evaluation report.")
    parser.add_argument("--report", required=True, help="Path to a single evaluation report JSON file.")
    parser.add_argument("--reports-dir", help="Optional directory containing multiple report JSON files for trend charts.")
    parser.add_argument("--output-dir", required=True, help="Directory where charts will be written.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    report_path = Path(args.report)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    report = load_report(report_path)
    reports = [report]

    if args.reports_dir:
        report_dir = Path(args.reports_dir)
        loaded_reports = []
        report_paths = sorted(report_dir.glob("*.json"))
        for path in report_paths:
            payload = load_report(path)
            if is_evaluation_report(payload):
                loaded_reports.append(payload)

        reports = loaded_reports or [report]
        if report_path not in report_paths and is_evaluation_report(report):
            reports.append(report)

    frame = flatten_examples(report)
    images = [
        save_summary_chart(report, output_dir),
        save_f1_chart(report, frame, output_dir),
        save_example_chart(frame, output_dir),
        save_delta_chart(frame, output_dir),
        save_judge_scatter(frame, output_dir),
    ]
    write_dashboard_metadata(report_path, output_dir, images)


if __name__ == "__main__":
    main()
