import typer


def main(fp_in: str, fp_out: str):
    from gensim.models import KeyedVectors

    try:
        wv = KeyedVectors.load_word2vec_format(fp_in, binary=True)
        wv.save_word2vec_format(fp_out, binary=False)
    except UnicodeDecodeError:
        raise ValueError("Seems like the source vectors are not binary.")


if __name__ == "__main__":
    typer.run(main)
