"""Converte os cinco mapas Python de referência sem importar/executar o projeto.

Uso: python scripts/importar_fases_modelo.py CAMINHO/src/levels/__init__.py
"""

from __future__ import annotations

import argparse
import ast
import json
import math
import operator
from pathlib import Path


ARQUIVOS = (
    "salto_curto",
    "na_diagonal",
    "curva_suave",
    "escala_segura",
    "entre_asteroides",
)
DICAS = (
    "Arraste para a esquerda e um pouco para baixo. Use a prévia para contornar o satélite até a Terra.",
    "Arraste quase para a esquerda. Os planetas curvam o voo pelo corredor até a Terra.",
    "Pouse no satélite superior esquerdo, depois no da direita. Ajuste cada salto pela prévia até a Terra.",
    "Passe por baixo do Sol. Use a prévia para atravessar os portões até a Terra.",
    "Passe abaixo dos dois sóis. Depois da faixa de asteroides, corrija para cima e à direita.",
)


def linha_asteroides(p0, p1, count, jitter=14, radius_range=(9, 18)):
    """Mesma distribuição determinística do modelo, inclusive os raios cíclicos."""
    resultado = []
    for indice in range(count):
        proporcao = indice / (count - 1) if count > 1 else 0.0
        resultado.append(
            {
                "pos": [
                    p0[0] + (p1[0] - p0[0]) * proporcao + math.sin(indice * 2.7) * jitter,
                    p0[1] + (p1[1] - p0[1]) * proporcao + math.cos(indice * 3.3) * jitter,
                ],
                "radius": radius_range[0] + (indice % 4) * 3,
            }
        )
    return resultado


def ponto_asteroide(pos, radius):
    return {"pos": list(pos), "radius": radius}


def cinturao_asteroides(largura, altura):
    margem = 75.0
    esquerda, direita = -margem, largura + margem
    topo, base = -margem, altura + margem
    cerca = (10, 16)
    return (
        linha_asteroides([esquerda, topo], [direita, topo], 12, jitter=8, radius_range=cerca)
        + linha_asteroides([esquerda, base], [direita, base], 12, jitter=8, radius_range=cerca)
        + linha_asteroides([esquerda, topo + 70], [esquerda, base - 70], 8, jitter=8, radius_range=cerca)
        + linha_asteroides([direita, topo + 70], [direita, base - 70], 8, jitter=8, radius_range=cerca)
        + [
            ponto_asteroide([-165, -165], 14),
            ponto_asteroide([largura + 165, -165], 14),
            ponto_asteroide([-165, altura + 165], 14),
            ponto_asteroide([largura + 165, altura + 165], 14),
        ]
    )


def dimensoes_janela(fonte: Path) -> tuple[int, int]:
    configuracoes = fonte.parent.parent / "core" / "configuracoes.py"
    modulo = ast.parse(configuracoes.read_text(encoding="utf-8-sig"))
    for declaracao in modulo.body:
        if isinstance(declaracao, ast.ClassDef) and declaracao.name == "ConfigJanela":
            campos = {
                item.target.id: ast.literal_eval(item.value)
                for item in declaracao.body
                if isinstance(item, ast.AnnAssign) and isinstance(item.target, ast.Name)
            }
            return int(campos["LARGURA"]), int(campos["ALTURA"])
    raise ValueError("ConfigJanela não encontrada nas configurações de referência")


def ler_modelos(fonte: Path) -> list[dict]:
    largura, altura = dimensoes_janela(fonte)
    nomes = {"SCREEN_WIDTH": largura, "SCREEN_HEIGHT": altura}
    funcoes = {
        "linha_asteroides": linha_asteroides,
        "ponto_asteroide": ponto_asteroide,
        "cinturao_asteroides": lambda: cinturao_asteroides(largura, altura),
    }
    operadores = {
        ast.Add: operator.add,
        ast.Sub: operator.sub,
        ast.Mult: operator.mul,
        ast.Div: operator.truediv,
        ast.FloorDiv: operator.floordiv,
    }

    def valor(no):
        if isinstance(no, ast.Constant):
            return no.value
        if isinstance(no, ast.Name) and no.id in nomes:
            return nomes[no.id]
        if isinstance(no, ast.List):
            return [valor(item) for item in no.elts]
        if isinstance(no, ast.Tuple):
            return tuple(valor(item) for item in no.elts)
        if isinstance(no, ast.Dict):
            return {valor(chave): valor(item) for chave, item in zip(no.keys, no.values)}
        if isinstance(no, ast.UnaryOp) and isinstance(no.op, ast.USub):
            return -valor(no.operand)
        if isinstance(no, ast.BinOp) and type(no.op) in operadores:
            return operadores[type(no.op)](valor(no.left), valor(no.right))
        if isinstance(no, ast.Call) and isinstance(no.func, ast.Name) and no.func.id in funcoes:
            return funcoes[no.func.id](
                *(valor(argumento) for argumento in no.args),
                **{argumento.arg: valor(argumento.value) for argumento in no.keywords},
            )
        raise ValueError("Expressão não suportada nos dados de referência: " + ast.dump(no))

    modulo = ast.parse(fonte.read_text(encoding="utf-8-sig"))
    modelos = {}
    esperados = {f"NIVEL_{indice}" for indice in range(1, 6)}
    for declaracao in modulo.body:
        if isinstance(declaracao, ast.Assign) and len(declaracao.targets) == 1:
            alvo = declaracao.targets[0]
            if isinstance(alvo, ast.Name) and alvo.id in esperados:
                modelos[alvo.id] = valor(declaracao.value)
    if modelos.keys() != esperados:
        raise ValueError("O modelo deve definir NIVEL_1 até NIVEL_5")
    return [modelos[f"NIVEL_{indice}"] for indice in range(1, 6)]


def corpo(id_corpo, tipo, posicao, raio, massa=0, proximidade=None):
    perigoso = tipo in ("sun", "asteroid")
    resultado = {
        "id": id_corpo,
        "type": tipo,
        "position": posicao,
        "mass": massa,
        "visual_radius": raio,
        "collision_radius": raio,
        "capture_radius": 0 if perigoso else raio,
        "danger_radius": raio if perigoso else 0,
        "proximity_radius": proximidade if proximidade is not None else max(raio * 2, raio + 8),
    }
    if tipo in ("planet", "satellite", "sun"):
        resultado["show_proximity"] = True
    return resultado


def converter(modelo: dict, indice: int) -> dict:
    corpos = []
    for numero, planeta in enumerate(modelo["planets"], start=1):
        raio = planeta["radius"]
        corpos.append(
            corpo(
                f"apoio_{numero}", planeta["type"], planeta["pos"], raio,
                planeta["mass"] * 1000, raio + 55 * math.sqrt(planeta["mass"]),
            )
        )
    for numero, estrela in enumerate(modelo.get("stars", []), start=1):
        corpos.append(
            corpo(
                f"sol_{numero}", "sun", estrela["pos"], estrela["radius"],
                estrela["mass"] * 1000, estrela["danger_radius"],
            )
        )
    for numero, asteroide in enumerate(modelo["asteroids"], start=1):
        corpos.append(corpo(f"asteroide_{numero:03d}", "asteroid", asteroide["pos"], asteroide["radius"]))
    terra = corpo("terra", "earth", modelo["home_star"], 16, proximidade=45)
    terra.pop("type")
    nota = (
        f"Modelo dev-macb/orbt/src/levels/__init__.py::NIVEL_{indice}. "
        "Coordenadas e raios 1:1; G=500 e massas multiplicadas por 1000 preservam GM do modelo. "
        "Nave começa livre e parada. Anéis indicam proximidade; só a superfície do Sol é fatal, como no código original. "
        "Órbitas adaptadas para corpos estáticos nas posições autorais."
    )
    if modelo.get("blackholes"):
        nota += " O atalho opcional por buraco negro foi omitido; a rota pelos satélites permanece disponível."
    return {
        "schema_version": 1,
        "content_version": 2,
        "id": ARQUIVOS[indice - 1],
        "name": modelo["name"],
        "order": indice + 1,
        "reference_level": indice,
        "bounds": {"position": [-200, -200], "size": [1300, 1000]},
        "initial_fuel": modelo["fuel"],
        "flight_timeout": 30,
        "physics": {"gravity_constant": 500, "softening": 1},
        "ship": {"radius": 6, "mass": 1, "dead_zone": 10, "max_drag": 80, "max_impulse": 260},
        "start": {"position": modelo["player_start"]},
        "camera": {"zoom": 0.5, "overview": {"position": [-30, -30], "size": [960, 660]}},
        "goal": terra,
        "bodies": corpos,
        "tutorial": DICAS[indice - 1],
        "notes": nota,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Arquivo src/levels/__init__.py do projeto de referência")
    parser.add_argument("--output-dir", type=Path, default=Path(__file__).resolve().parents[1] / "Recursos" / "Fases")
    argumentos = parser.parse_args()
    modelos = ler_modelos(argumentos.source)
    argumentos.output_dir.mkdir(parents=True, exist_ok=True)
    for indice, modelo in enumerate(modelos, start=1):
        destino = argumentos.output_dir / (ARQUIVOS[indice - 1] + ".json")
        destino.write_text(json.dumps(converter(modelo, indice), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"{destino.name}: {modelo['name']} ({len(modelo['asteroids'])} asteroides)")


if __name__ == "__main__":
    main()
