Clairvoyance
============

.. image:: logo.png
    :width: 300px
    :alt: Doublade logo
    :align: center

.. note::
    **For responses, please see** Response_.

In, our empirical study, we conduct comparison on the effectiveness among tools and evaluation on results by scanning the implementation of tools. The study was completed on a dataset with **76354** smart contracts. Also, we list several real code which are suspiciously vulnerable and exhibit exploitations on our pages.

.. _Response:

Response to comments:
---------------------

1.  **Response to reviewer's on 74 TPs of Clairvoyance**

The 76 real world vulnerabilities found by Clairvoyance is published in `Google Drive <https://drive.google.com/file/d/1wpDYHV_velfbA-Y_pPH79gT_ljiQxoKR/view>`_. And we provide 20 influential smart contract expolits, all of which are programed by our expert and tested by `Remix IDE <https://remix.ethereum.org/>`_. They are listed in the followings.

.. toctree::
    :maxdepth: 2

    evaluations.rst
    expolits.rst
    suppliments.rst

2.  **Response to reviewer's on the implicit evaluations**


Obviously, our proposed tool, Clarivoyance, can cover most real vulnerability except 28 ones found by other tools (**17 of Slither, 11 of Securify**). The reasons can be categorized into three: 

1.  Inheritable *internal* vulnerable function. Solidity function use functional modifiers to limit the viewability of outer callers. As one of them, *internal* limit that the function can only be seen by functions have inheritable relations with. If a vulnerable function has such modifier, it can only be hacked theoretically. Because the attacked function must inheritate from the attack one, and we believe this means a trust relationship. So this case is exclued from Clarivoyance's capability. We found 10 vulnerabilities in this case, **8** of them are reported by Securify and **10** of them are reported by Slither.

2.  Misusing PPTs. In some cases, PPTs can miss the vulnerability. For example, our PPT1, the use of identity check before other operations, can lead us missing vulnerabilities because the check may contain irrelevant equations, which make the check useless to stop malicious investigators. In our observation, the misusing can happen when adopt PPT1-PPT3. In our work, we found 10 vulnerabilities misusing PPTs, **3** of them are from Securify and **7** of them are from Slither.

.. 3.  Bypassable permission control. Solidity functions have statements *require*, *assert* to verify equations. Part of these statements are used to permission control. But these equations may become ineffective due to weak conditions. After human auditing by our experts, we found **8** vulnerabilities in total. **5** of them are from Slither, and **3** of them are from Securify.

All of our cases mentioned above can be found in `Google Drive <https://drive.google.com/file/d/1yaOR-dTEeghyTuxYJa3QwS_2nQPWz4bi/view?usp=sharing>`_.