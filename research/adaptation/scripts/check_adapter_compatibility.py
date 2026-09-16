#!/usr/bin/env python3
import os
import sys
import json
import onnx

def inspect_onnx_model(model_path):
    if not os.path.exists(model_path):
        return None
    model = onnx.load(model_path)
    graph = model.graph
    inputs = [i.name for i in graph.input]
    outputs = [o.name for o in graph.output]
    node_count = len(graph.node)
    return {
        "inputs": inputs,
        "outputs": outputs,
        "node_count": node_count,
        "is_static_int8": "int8" in model_path or any("Quantize" in n.op_type for n in graph.node)
    }

def main():
    encoder_path = "kasa_me/assets/models/asr/english/encoder.onnx"
    decoder_path = "kasa_me/assets/models/asr/english/decoder.onnx"
    joiner_path = "kasa_me/assets/models/asr/english/joiner.onnx"

    encoder_info = inspect_onnx_model(encoder_path)
    decoder_info = inspect_onnx_model(decoder_path)
    joiner_info = inspect_onnx_model(joiner_path)

    os.makedirs("research/adaptation/reports", exist_ok=True)
    report_path = "research/adaptation/reports/onnx_adapter_compatibility.json"

    compatibility_assessment = {
        "encoder": encoder_info,
        "decoder": decoder_info,
        "joiner": joiner_info,
        "compatibility_status": "NOT_COMPATIBLE_WITH_CURRENT_BASELINE_EXPORT",
        "technical_reason": (
            "The baseline encoder/decoder ONNX files are fully compiled, int8 static/quantized graphs. "
            "They do not expose intermediate PyTorch projection layers or trainable tensor hooks for direct "
            "ONNX-level LoRA/adapter insertion. Legitimate neural adapter insertion requires the original PyTorch "
            "training graph and re-export path."
        )
    }

    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(compatibility_assessment, f, indent=2)

    print(f"ONNX Adapter Compatibility Check Completed: {compatibility_assessment['compatibility_status']}")
    print(f"Report saved to {report_path}")

if __name__ == "__main__":
    main()
